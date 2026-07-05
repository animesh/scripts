@echo off
setlocal EnableDelayedExpansion
:: diannrunDB v3.1 -- DuckDB ingestion for DIA-NN report.parquet output
:: Builds ONLY proteinGroupsDIA. Skips only if proteinGroupsDIA already has rows.
:: If ingested_runs_dia has a stale marker but proteinGroupsDIA has zero rows,
:: the stale marker is deleted and ingestion is retried.

set "QC_ROOT=F:\promec\TIMSTOF\QC\DIA"
set "DUCKDB_BIN=C:\Program Files\DuckDB\duckdb.exe"
set "DB_FILE=%QC_ROOT%\diannrun.duckdb"
if not exist "%DUCKDB_BIN%" exit /b 1
if "%~1" NEQ "" set "SINGLE_RUN=%~1"
echo Starting diannrunDB: %DATE% %TIME%

set "INIT_SQL=%QC_ROOT%\diannrunDB_init.sql"
> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS ingested_runs_dia(run_id VARCHAR PRIMARY KEY,n_protein_groups INTEGER,ingested_at TIMESTAMP DEFAULT current_timestamp);
>> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS proteinGroupsDIA(run_id VARCHAR NOT NULL,
>> "%INIT_SQL%" echo "Protein.Group" VARCHAR NOT NULL,
>> "%INIT_SQL%" echo "Protein.Ids" VARCHAR,
>> "%INIT_SQL%" echo "Genes" VARCHAR,
>> "%INIT_SQL%" echo "Protein.Names" VARCHAR,
>> "%INIT_SQL%" echo "Peptides" INTEGER,
>> "%INIT_SQL%" echo "Proteotypic peptides" INTEGER,
>> "%INIT_SQL%" echo "Precursors" INTEGER,
>> "%INIT_SQL%" echo "PG.Q.Value" DOUBLE,
>> "%INIT_SQL%" echo "PG.MaxLFQ" DOUBLE,
>> "%INIT_SQL%" echo "Genes.MaxLFQ" DOUBLE,
>> "%INIT_SQL%" echo "Precursor.Quantity.Sum" DOUBLE,
>> "%INIT_SQL%" echo "Precursor.Quantity.Median" DOUBLE,
>> "%INIT_SQL%" echo "Peptide sequences" VARCHAR,
>> "%INIT_SQL%" echo ingested_at TIMESTAMP DEFAULT current_timestamp,PRIMARY KEY(run_id,"Protein.Group"));
"%DUCKDB_BIN%" "%DB_FILE%" -f "%INIT_SQL%" >nul 2>&1
del "%INIT_SQL%" 2>nul

:poll_loop
call :count start
if defined SINGLE_RUN (set "LOOP_GLOB=%QC_ROOT%\%SINGLE_RUN%") else (set "LOOP_GLOB=%QC_ROOT%\*")
for /d %%P in ("%LOOP_GLOB%") do call :ingest "%%~fP" "%%~nxP"
call :count end
if defined SINGLE_RUN exit /b 0
echo %DATE% %TIME% Sleeping 900s
timeout /t 900 /nobreak >nul
goto :poll_loop

:ingest
setlocal EnableDelayedExpansion
set "RUN_PATH=%~1"
set "RUN_NAME=%~2"
set "PARQUET=%RUN_PATH%\%RUN_NAME%.d.report.parquet"
if not exist "%PARQUET%" endlocal & exit /b 0
for %%S in ("%PARQUET%") do set "SZ=%%~zS"
if "%SZ%"=="0" echo %DATE% %TIME% SKIP %RUN_NAME% (empty) & endlocal & exit /b 0

set "CK=%QC_ROOT%\ck_%RUN_NAME%.sql"
set "CO=%QC_ROOT%\ck_%RUN_NAME%.csv"
> "%CK%" echo COPY(SELECT COUNT(*) FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%')TO '%CO%'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%CK%" >nul 2>&1
set "N=0"
if exist "%CO%" for /f "usebackq delims=" %%I in ("%CO%") do set "N=%%I"
del "%CK%" "%CO%" 2>nul
if "%N%" NEQ "0" echo %DATE% %TIME% SKIP %RUN_NAME% (done, %N% protein groups) & endlocal & exit /b 0

set "SM=%QC_ROOT%\stale_%RUN_NAME%.sql"
> "%SM%" echo DELETE FROM ingested_runs_dia WHERE run_id='%RUN_NAME%';
"%DUCKDB_BIN%" "%DB_FILE%" -f "%SM%" >nul 2>&1
del "%SM%" 2>nul

echo %DATE% %TIME% START %RUN_NAME%
set "PARQUET_SL=%PARQUET:\=/%"
set "SQL=%QC_ROOT%\dn_%RUN_NAME%.sql"
> "%SQL%" echo BEGIN TRANSACTION;
>> "%SQL%" echo CREATE TEMP TABLE _src AS SELECT * FROM read_parquet('%PARQUET_SL%') WHERE "Decoy"=0;
>> "%SQL%" echo DELETE FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%';
>> "%SQL%" echo INSERT INTO proteinGroupsDIA(run_id,
>> "%SQL%" echo "Protein.Group","Protein.Ids","Genes","Protein.Names",
>> "%SQL%" echo "Peptides","Proteotypic peptides","Precursors",
>> "%SQL%" echo "PG.Q.Value","PG.MaxLFQ","Genes.MaxLFQ",
>> "%SQL%" echo "Precursor.Quantity.Sum","Precursor.Quantity.Median",
>> "%SQL%" echo "Peptide sequences",ingested_at)
>> "%SQL%" echo SELECT '%RUN_NAME%',
>> "%SQL%" echo "Protein.Group",ANY_VALUE("Protein.Ids"),ANY_VALUE("Genes"),ANY_VALUE("Protein.Names"),
>> "%SQL%" echo COUNT(DISTINCT "Stripped.Sequence"),
>> "%SQL%" echo COUNT(DISTINCT "Stripped.Sequence") FILTER (WHERE "Proteotypic"=1),
>> "%SQL%" echo COUNT(DISTINCT "Precursor.Id"),MAX("PG.Q.Value"),MAX("PG.MaxLFQ"),MAX("Genes.MaxLFQ"),
>> "%SQL%" echo SUM("Precursor.Quantity"),MEDIAN("Precursor.Quantity"),string_agg(DISTINCT "Stripped.Sequence", ';'),current_timestamp
>> "%SQL%" echo FROM _src GROUP BY "Protein.Group";
>> "%SQL%" echo INSERT OR REPLACE INTO ingested_runs_dia(run_id,n_protein_groups,ingested_at)
>> "%SQL%" echo SELECT '%RUN_NAME%',COUNT(*),current_timestamp FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%' HAVING COUNT(*) ^> 0;
>> "%SQL%" echo COMMIT;
>> "%SQL%" echo COPY(SELECT COUNT(*) FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%')TO '%SQL%.csv'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%SQL%"
set "EX=%ERRORLEVEL%"
set "RC=0"
if exist "%SQL%.csv" for /f "usebackq delims=" %%R in ("%SQL%.csv") do set "RC=%%R"
del "%SQL%" "%SQL%.csv" 2>nul
if "%EX%" NEQ "0" (echo %DATE% %TIME% ERROR %RUN_NAME% & endlocal & exit /b 1)
if "!RC!"=="0" (echo %DATE% %TIME% WARN %RUN_NAME% ingested 0 protein groups & endlocal & exit /b 0)
echo %DATE% %TIME% DONE %RUN_NAME% (!RC! protein groups)
endlocal & exit /b 0

:count
setlocal
set "S=%QC_ROOT%\cnt_%~1.sql"
set "O=%QC_ROOT%\cnt_%~1.csv"
> "%S%" echo COPY(SELECT CASE WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name='proteinGroupsDIA')THEN(SELECT COUNT(*) FROM proteinGroupsDIA)ELSE 0 END)TO '%O%'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%S%" >nul 2>&1
set "R=0"
if exist "%O%" for /f "usebackq delims=" %%R in ("%O%") do set "R=%%R"
del "%S%" "%O%" 2>nul
echo %DATE% %TIME% DB protein-group rows [%~1]: %R%
endlocal & exit /b 0
