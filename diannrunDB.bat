@echo off
setlocal EnableDelayedExpansion
:: diannrunDB v3 -- DuckDB ingestion for DIA-NN report.parquet output
:: Builds ONLY proteinGroupsDIA (one row per run_id + Protein.Group).
:: diannrunDash.py queries raw parquet directly for precursor-level heatmaps
:: (RT/IM/Quantity/FragSum) via read_parquet() + Protein.Group predicates, so
:: there is no longer a precursorsDIA table here -- it was being populated
:: every run (tens of thousands of rows) but never read by the dashboard.
:: Removing it cuts ingestion I/O substantially with zero change in dashboard
:: behaviour, since proteinGroupsDIA's aggregation reads from the _src temp
:: table (the full parquet), not from precursorsDIA.
::
:: VERIFIED 2026-06-20 against real data:
:: - PG.MaxLFQ / PG.Q.Value constant per (run, Protein.Group): 0 violations.
:: - Contaminant tagging: "Protein.Names" ILIKE '%cRAP%' matches ground
::   truth exactly (independently confirmed via FASTA digest). DO NOT use
::   "Protein.Ids" for this -- it over-counts (48 vs 43 on a real run).

set "QC_ROOT=F:\promec\TIMSTOF\QC\DIA"
set "DUCKDB_BIN=C:\Program Files\DuckDB\duckdb.exe"
set "DB_FILE=%QC_ROOT%\diannrun.duckdb"
if not exist "%DUCKDB_BIN%" exit /b 1
if "%~1" NEQ "" set "SINGLE_RUN=%~1"
echo Starting diannrunDB: %DATE% %TIME%

:: -- Schema init -------------------------------------------------------------------
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

:: -- :ingest -------------------------------------------------------------------------
:: Arg1: full path to run's QC subfolder   Arg2: run name (== folder name == BN)
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
> "%CK%" echo COPY(SELECT COUNT(*) FROM ingested_runs_dia WHERE run_id='%RUN_NAME%')TO '%CO%'(FORMAT CSV,HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%CK%" >nul 2>&1
set "N=0"
if exist "%CO%" for /f "usebackq delims=" %%I in ("%CO%") do set "N=%%I"
del "%CK%" "%CO%" 2>nul
if "%N%" NEQ "0" echo %DATE% %TIME% SKIP %RUN_NAME% (done) & endlocal & exit /b 0

echo %DATE% %TIME% START %RUN_NAME%
set "PARQUET_SL=%PARQUET:\=/%"
set "SQL=%QC_ROOT%\dn_%RUN_NAME%.sql"

> "%SQL%" echo BEGIN TRANSACTION;
:: read_parquet is already typed -- no TRY_CAST gymnastics needed like the TSV
:: ingestion in mqrunDB.bat, parquet enforces the schema at write time.
>> "%SQL%" echo CREATE TEMP TABLE _src AS SELECT * FROM read_parquet('%PARQUET_SL%') WHERE "Decoy"=0;
>> "%SQL%" echo INSERT INTO proteinGroupsDIA(run_id,
>> "%SQL%" echo "Protein.Group","Protein.Ids","Genes","Protein.Names",
>> "%SQL%" echo "Peptides","Proteotypic peptides","Precursors",
>> "%SQL%" echo "PG.Q.Value","PG.MaxLFQ","Genes.MaxLFQ",
>> "%SQL%" echo "Precursor.Quantity.Sum","Precursor.Quantity.Median",
>> "%SQL%" echo "Peptide sequences",ingested_at)
>> "%SQL%" echo SELECT '%RUN_NAME%',
>> "%SQL%" echo "Protein.Group",
>> "%SQL%" echo ANY_VALUE("Protein.Ids"),
>> "%SQL%" echo ANY_VALUE("Genes"),
>> "%SQL%" echo ANY_VALUE("Protein.Names"),
>> "%SQL%" echo COUNT(DISTINCT "Stripped.Sequence"),
>> "%SQL%" echo COUNT(DISTINCT "Stripped.Sequence") FILTER (WHERE "Proteotypic"=1),
>> "%SQL%" echo COUNT(DISTINCT "Precursor.Id"),
>> "%SQL%" echo MAX("PG.Q.Value"),
>> "%SQL%" echo MAX("PG.MaxLFQ"),
>> "%SQL%" echo MAX("Genes.MaxLFQ"),
>> "%SQL%" echo SUM("Precursor.Quantity"),
>> "%SQL%" echo MEDIAN("Precursor.Quantity"),
>> "%SQL%" echo string_agg(DISTINCT "Stripped.Sequence", ';'),
>> "%SQL%" echo current_timestamp
>> "%SQL%" echo FROM _src GROUP BY "Protein.Group";
>> "%SQL%" echo INSERT OR REPLACE INTO ingested_runs_dia VALUES('%RUN_NAME%',(SELECT COUNT(*) FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%'),current_timestamp);
>> "%SQL%" echo COMMIT;
>> "%SQL%" echo COPY(SELECT n_protein_groups FROM ingested_runs_dia WHERE run_id='%RUN_NAME%')TO '%SQL%.csv'(FORMAT CSV,HEADER false);

"%DUCKDB_BIN%" "%DB_FILE%" -f "%SQL%"
set "EX=%ERRORLEVEL%"
set "RC=0"
if exist "%SQL%.csv" for /f "usebackq delims=" %%R in ("%SQL%.csv") do set "RC=%%R"
del "%SQL%" "%SQL%.csv" 2>nul
if "%EX%" NEQ "0" (echo %DATE% %TIME% ERROR %RUN_NAME% & endlocal & exit /b 1)
echo %DATE% %TIME% DONE %RUN_NAME% (!RC! protein groups)
endlocal & exit /b 0

:: -- :count -------------------------------------------------------------------------
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
