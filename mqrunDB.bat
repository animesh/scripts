@echo off
setlocal EnableDelayedExpansion
set "QC_ROOT=L:\promec\TIMSTOF\QC"
set "DUCKDB_BIN=%QC_ROOT%\duckdb.exe"
set "DB_FILE=%QC_ROOT%\mqrun.duckdb"
set "PG_REL=combined\txt\proteinGroups.txt"
if not exist "%DUCKDB_BIN%" exit /b 1
if "%~1" NEQ "" set "SINGLE_RUN=%~1"
echo Starting mqrunDB: %DATE% %TIME%
set "INIT_SQL=%QC_ROOT%\mqrunDB_init.sql"
> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS ingested_runs(run_id VARCHAR PRIMARY KEY,row_count INTEGER,ingested_at TIMESTAMP DEFAULT current_timestamp);
>> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS proteinGroups(run_id VARCHAR NOT NULL,
>> "%INIT_SQL%" echo "Protein IDs" VARCHAR,
>> "%INIT_SQL%" echo "Gene names" VARCHAR,
>> "%INIT_SQL%" echo "Protein names" VARCHAR,
>> "%INIT_SQL%" echo "Peptides" INTEGER,
>> "%INIT_SQL%" echo "Unique peptides" INTEGER,
>> "%INIT_SQL%" echo "Razor + unique peptides" INTEGER,
>> "%INIT_SQL%" echo "Sequence coverage [%%]" DOUBLE,
>> "%INIT_SQL%" echo "Mol. weight [kDa]" DOUBLE,
>> "%INIT_SQL%" echo "Sequence length" INTEGER,
>> "%INIT_SQL%" echo "Q-value" DOUBLE,
>> "%INIT_SQL%" echo "Score" DOUBLE,
>> "%INIT_SQL%" echo "Intensity" DOUBLE,
>> "%INIT_SQL%" echo "iBAQ peptides" INTEGER,
>> "%INIT_SQL%" echo "iBAQ" DOUBLE,
>> "%INIT_SQL%" echo "Top3" DOUBLE,
>> "%INIT_SQL%" echo "Peptide sequences" VARCHAR,
>> "%INIT_SQL%" echo "Evidence IDs" VARCHAR,
>> "%INIT_SQL%" echo "MS/MS IDs" VARCHAR,
>> "%INIT_SQL%" echo "Only identified by site" VARCHAR,
>> "%INIT_SQL%" echo "Reverse" VARCHAR,
>> "%INIT_SQL%" echo "Potential contaminant" VARCHAR,
>> "%INIT_SQL%" echo "id" INTEGER,
>> "%INIT_SQL%" echo ingested_at TIMESTAMP DEFAULT current_timestamp,PRIMARY KEY(run_id,"id"));
"%DUCKDB_BIN%" "%DB_FILE%" -f "%INIT_SQL%" >nul 2>&1
del "%INIT_SQL%" 2>nul
:poll_loop
call :count start
if defined SINGLE_RUN (set "LOOP_GLOB=%QC_ROOT%\%SINGLE_RUN%") else (set "LOOP_GLOB=%QC_ROOT%\*")
for /d %%P in ("%LOOP_GLOB%") do call :ingest "%%~fP" "%%~nxP"
call :count end
if defined SINGLE_RUN exit /b 0
echo %DATE% %TIME% Sleeping 3600s
timeout /t 3600 /nobreak >nul
goto :poll_loop

:ingest
setlocal EnableDelayedExpansion
set "RUN_PATH=%~1"
set "RUN_NAME=%~2"
set "PG=%RUN_PATH%\%PG_REL%"
if not exist "%PG%" endlocal & exit /b 0
for %%S in ("%PG%") do set "SZ=%%~zS"
if "%SZ%"=="0" echo %DATE% %TIME% SKIP %RUN_NAME% (empty) & endlocal & exit /b 0
set "CK=%QC_ROOT%\ck_%RUN_NAME%.sql"
set "CO=%QC_ROOT%\ck_%RUN_NAME%.csv"
> "%CK%" echo COPY(SELECT COUNT(*) FROM ingested_runs WHERE run_id='%RUN_NAME%')TO '%CO%'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%CK%" >nul 2>&1
set "N=0"
if exist "%CO%" for /f "usebackq delims=" %%I in ("%CO%") do set "N=%%I"
del "%CK%" "%CO%" 2>nul
if "%N%" NEQ "0" echo %DATE% %TIME% SKIP %RUN_NAME% (done) & endlocal & exit /b 0
echo %DATE% %TIME% START %RUN_NAME%
set "PG_SL=%PG:\=/%"
set "SQL=%QC_ROOT%\mq_%RUN_NAME%.sql"
> "%SQL%" echo BEGIN TRANSACTION;
>> "%SQL%" echo INSERT INTO proteinGroups(run_id,
>> "%SQL%" echo "Protein IDs",
>> "%SQL%" echo "Gene names",
>> "%SQL%" echo "Protein names",
>> "%SQL%" echo "Peptides",
>> "%SQL%" echo "Unique peptides",
>> "%SQL%" echo "Razor + unique peptides",
>> "%SQL%" echo "Sequence coverage [%%]",
>> "%SQL%" echo "Mol. weight [kDa]",
>> "%SQL%" echo "Sequence length",
>> "%SQL%" echo "Q-value",
>> "%SQL%" echo "Score",
>> "%SQL%" echo "Intensity",
>> "%SQL%" echo "iBAQ peptides",
>> "%SQL%" echo "iBAQ",
>> "%SQL%" echo "Top3",
>> "%SQL%" echo "Peptide sequences",
>> "%SQL%" echo "Evidence IDs",
>> "%SQL%" echo "MS/MS IDs",
>> "%SQL%" echo "Only identified by site",
>> "%SQL%" echo "Reverse",
>> "%SQL%" echo "Potential contaminant",
>> "%SQL%" echo "id",
>> "%SQL%" echo ingested_at) SELECT '%RUN_NAME%',
>> "%SQL%" echo TRY_CAST("Protein IDs" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Gene names" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Protein names" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Peptides" AS INTEGER),
>> "%SQL%" echo TRY_CAST("Unique peptides" AS INTEGER),
>> "%SQL%" echo TRY_CAST("Razor + unique peptides" AS INTEGER),
>> "%SQL%" echo TRY_CAST("Sequence coverage [%%]" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Mol. weight [kDa]" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Sequence length" AS INTEGER),
>> "%SQL%" echo TRY_CAST("Q-value" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Score" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Intensity" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("iBAQ peptides" AS INTEGER),
>> "%SQL%" echo TRY_CAST("iBAQ" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Top3" AS DOUBLE),
>> "%SQL%" echo TRY_CAST("Peptide sequences" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Evidence IDs" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("MS/MS IDs" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Only identified by site" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Reverse" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("Potential contaminant" AS VARCHAR),
>> "%SQL%" echo TRY_CAST("id" AS INTEGER),
>> "%SQL%" echo current_timestamp FROM read_csv_auto('%PG_SL%',delim=chr(9),header=true,ignore_errors=true);
>> "%SQL%" echo INSERT OR REPLACE INTO ingested_runs VALUES('%RUN_NAME%',(SELECT COUNT(*) FROM proteinGroups WHERE run_id='%RUN_NAME%'),current_timestamp);
>> "%SQL%" echo COMMIT;
>> "%SQL%" echo COPY(SELECT row_count FROM ingested_runs WHERE run_id='%RUN_NAME%')TO '%SQL%.csv'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%SQL%"
set "EX=%ERRORLEVEL%"
set "RC=0"
if exist "%SQL%.csv" for /f "usebackq delims=" %%R in ("%SQL%.csv") do set "RC=%%R"
del "%SQL%" "%SQL%.csv" 2>nul
if "%EX%" NEQ "0" (echo %DATE% %TIME% ERROR %RUN_NAME% & endlocal & exit /b 1)
echo %DATE% %TIME% DONE %RUN_NAME% (%RC% rows)
endlocal & exit /b 0

:count
setlocal
set "S=%QC_ROOT%\cnt_%~1.sql"
set "O=%QC_ROOT%\cnt_%~1.csv"
> "%S%" echo COPY(SELECT CASE WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name='proteinGroups')THEN(SELECT COUNT(*) FROM proteinGroups)ELSE 0 END)TO '%O%'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%S%" >nul 2>&1
set "R=0"
if exist "%O%" for /f "usebackq delims=" %%R in ("%O%") do set "R=%%R"
del "%S%" "%O%" 2>nul
echo %DATE% %TIME% DB rows [%~1]: %R%
endlocal & exit /b 0
