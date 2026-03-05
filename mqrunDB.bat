@echo off
setlocal EnableDelayedExpansion

set "QC_ROOT=L:\promec\TIMSTOF\QC"
set "DUCKDB_BIN=%QC_ROOT%\duckdb.exe"
set "DB_FILE=%QC_ROOT%\mqrun.duckdb"
set "PG_REL=combined\txt\proteinGroups.txt"
set "RAW_FILTER=lower(column_name) NOT LIKE '%%d:\tmpdir\raw_up000005640_9606_1protein1gene%%'"

if "%~1" NEQ "" set "SINGLE_RUN=%~1"

if not exist "%DUCKDB_BIN%" exit /b 1
if not exist "%QC_ROOT%" mkdir "%QC_ROOT%"

echo Starting mqrunDB: %DATE% %TIME%
echo QC_ROOT=%QC_ROOT%

set "INIT_SQL=%QC_ROOT%\mqrunDB_init.sql"
> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS ingested_runs(run_id VARCHAR PRIMARY KEY, ingested_at TIMESTAMP DEFAULT current_timestamp);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%INIT_SQL%" > nul 2>&1

if defined SINGLE_RUN (
  set "LOOP_GLOB=%QC_ROOT%\%SINGLE_RUN%"
) else (
  set "LOOP_GLOB=%QC_ROOT%\*"
)

if exist "%DB_FILE%" (
  call :mq_db_count start
) else (
  echo %DATE% %TIME% DB file %DB_FILE% not found
)

for /d %%P in ("%LOOP_GLOB%") do (
  call :ingest_run "%%~fP" "%%~nxP"
)

if exist "%DB_FILE%" (
  call :mq_db_count end
) else (
  echo %DATE% %TIME% DB file %DB_FILE% not found
)

exit /b 0

:ingest_run
setlocal EnableDelayedExpansion
set "RUN_PATH=%~1"
set "RUN_NAME=%~2"

rem (removed verbose Checking line)

set "PG_FILE=%RUN_PATH%\%PG_REL%"
if not exist "%PG_FILE%" endlocal & exit /b 0

set "PG_FILE_SLASH=%PG_FILE:\=/%"

for %%S in ("%PG_FILE%") do set "PG_SIZE=%%~zS"
if "%PG_SIZE%"=="0" (
  echo %DATE% %TIME% %RUN_NAME% proteinGroups.txt is empty - skipping
  endlocal & exit /b 0
)

set "PG_LINES=0"
set "PG_LINES=0"
set "PG_COUNT_SQL=%QC_ROOT%\mq_file_count_%RUN_NAME%.sql"
set "PG_COUNT_OUT=%QC_ROOT%\mq_file_count_%RUN_NAME%.csv"
> "%PG_COUNT_SQL%" echo COPY (SELECT COUNT(*) FROM read_csv_auto('%PG_FILE_SLASH%', delim='\t', header=true)) TO '%PG_COUNT_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%PG_COUNT_SQL%" > nul 2>&1
if exist "%PG_COUNT_OUT%" for /f "usebackq delims=" %%N in ("%PG_COUNT_OUT%") do set "PG_LINES=%%N"
set /a PG_ROWS=PG_LINES-1
if %PG_ROWS% LSS 0 (set "PG_ROWS=0")
echo %DATE% %TIME% proteinGroups found and contains rows %PG_ROWS% (lines: %PG_LINES%)

set "STAGE_SQL=%QC_ROOT%\mq_stage_%RUN_NAME%.sql"
set "EXPORT_SQL=%QC_ROOT%\mq_export_%RUN_NAME%.sql"
set "COLS_CSV=%QC_ROOT%\mq_cols_%RUN_NAME%.csv"
set "FINAL_SQL=%QC_ROOT%\mq_final_%RUN_NAME%.sql"
set "COUNT_SQL=%QC_ROOT%\mq_count_%RUN_NAME%.sql"
set "COUNT_OUT=%QC_ROOT%\mq_count_%RUN_NAME%.csv"

if exist "%FINAL_SQL%" (
  echo %DATE% %TIME% Final SQL exists for %RUN_NAME% - skipping
  endlocal & exit /b 0
)

> "%COUNT_SQL%" echo COPY (SELECT (SELECT COUNT(*) FROM ingested_runs WHERE run_id = '%RUN_NAME%') + (SELECT COUNT(*) FROM proteinGroups WHERE run_id = '%RUN_NAME%')) TO '%COUNT_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%COUNT_SQL%" > nul 2>&1
set "COUNT=0"
if exist "%COUNT_OUT%" for /f "usebackq delims=" %%I in ("%COUNT_OUT%") do set "COUNT=%%I"
if "%COUNT%" NEQ "0" endlocal & exit /b 0

echo %DATE% %TIME% Ingesting: %RUN_NAME%

> "%STAGE_SQL%" echo DROP TABLE IF EXISTS __stg;
>> "%STAGE_SQL%" echo CREATE TABLE __stg AS SELECT * FROM read_csv_auto('%PG_FILE_SLASH%', delim='\t', header=true);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%STAGE_SQL%"

echo %DATE% %TIME% Staged __stg for %RUN_NAME%

> "%EXPORT_SQL%" echo COPY (SELECT '"' ^|^| REPLACE(column_name, '"', '""') ^|^| '"' FROM information_schema.columns WHERE table_name='__stg' AND !RAW_FILTER! ORDER BY ordinal_position) TO '%COLS_CSV%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%EXPORT_SQL%"

echo %DATE% %TIME% Exported column names to %COLS_CSV%

if not exist "%COLS_CSV%" endlocal & exit /b 1

set "COLS="
for /f "usebackq delims=" %%C in ("%COLS_CSV%") do (
  set "col=%%C"
  set "col=!col:"=!"
  if defined COLS (
    set "COLS=!COLS!, "!col!""
  ) else (
    set "COLS="!col!""
  )
)

> "%FINAL_SQL%" echo BEGIN TRANSACTION;
>> "%FINAL_SQL%" echo DROP TABLE IF EXISTS temp_import;
>> "%FINAL_SQL%" echo CREATE TABLE temp_import AS SELECT * FROM __stg;
>> "%FINAL_SQL%" echo ALTER TABLE temp_import ADD COLUMN IF NOT EXISTS run_id VARCHAR;
>> "%FINAL_SQL%" echo UPDATE temp_import SET run_id = '%RUN_NAME%';
>> "%FINAL_SQL%" echo CREATE TABLE IF NOT EXISTS proteinGroups AS SELECT * FROM __stg WHERE 1=0;
>> "%FINAL_SQL%" echo ALTER TABLE proteinGroups ADD COLUMN IF NOT EXISTS run_id VARCHAR;
>> "%FINAL_SQL%" echo INSERT INTO proteinGroups (%COLS%, run_id) SELECT %COLS%, run_id FROM temp_import;
>> "%FINAL_SQL%" echo INSERT OR REPLACE INTO ingested_runs(run_id, ingested_at) VALUES ('%RUN_NAME%', current_timestamp);
>> "%FINAL_SQL%" echo COMMIT;
call :mq_db_count %RUN_NAME%_before
"%DUCKDB_BIN%" "%DB_FILE%" -f "%FINAL_SQL%"
call :mq_db_count %RUN_NAME%_after

set "BEFORE_FILE=%QC_ROOT%\mq_db_count_%RUN_NAME%_before.csv"
set "AFTER_FILE=%QC_ROOT%\mq_db_count_%RUN_NAME%_after.csv"
set "BEFORE=0"
if exist "%BEFORE_FILE%" for /f "usebackq delims=" %%B in ("%BEFORE_FILE%") do set "BEFORE=%%B"
set "AFTER=0"
if exist "%AFTER_FILE%" for /f "usebackq delims=" %%A in ("%AFTER_FILE%") do set "AFTER=%%A"
set /a DIFF=AFTER - BEFORE
echo %DATE% %TIME% Rows before: %BEFORE% after: %AFTER% delta: %DIFF%

echo %DATE% %TIME% Finalized ingest for %RUN_NAME%

endlocal & exit /b 0

:mq_db_count
setlocal
set "SUF=%~1"
set "DB_COUNT_SQL=%QC_ROOT%\mq_db_count_%SUF%.sql"
set "DB_COUNT_OUT=%QC_ROOT%\mq_db_count_%SUF%.csv"
> "%DB_COUNT_SQL%" echo COPY (SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='proteinGroups') THEN (SELECT COUNT(*) FROM proteinGroups) ELSE 0 END) TO '%DB_COUNT_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%DB_COUNT_SQL%" > nul 2>&1
set "DB_RET=0"
if exist "%DB_COUNT_OUT%" for /f "usebackq delims=" %%R in ("%DB_COUNT_OUT%") do set "DB_RET=%%R"
echo %DATE% %TIME% DB rows %SUF%: %DB_RET%
endlocal & exit /b 0
