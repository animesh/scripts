@echo off
setlocal EnableDelayedExpansion
:: diannrunDB v1 -- DuckDB ingestion for DIA-NN report.parquet output
:: Analogous to mqrunDB.bat, adapted for precursor-level parquet input.
::
:: WHY THIS LOOKS DIFFERENT FROM mqrunDB.bat:
:: report.parquet is PRECURSOR-level (one row per precursor per run, ~100K+
:: rows/run), not protein-group level like proteinGroups.txt. There is no
:: DIA-NN file that is a direct equivalent of proteinGroups.txt, so this
:: script builds that aggregation itself via SQL on ingestion:
::   precursorsDIA    -- raw precursor rows, useful subset of columns (not all
::                        120 -- fragment-ion Fr.0..Fr.11 columns excluded)
::   proteinGroupsDIA -- ONE ROW PER (run, Protein.Group), aggregated from
::                        precursorsDIA. This is the table the dashboard reads,
::                        sized similarly to MaxQuant's proteinGroups table
::                        (thousands of rows/run, not hundreds of thousands).
::
:: ASSUMPTION (verify once with the query at the bottom of this file):
:: PG.MaxLFQ and PG.Q.Value are constant across all precursor rows sharing
:: the same (run, Protein.Group) -- DIA-NN broadcasts the protein-group-level
:: value onto every precursor row belonging to that group. MAX() is used
:: defensively to avoid NULL propagation if this ever isn't perfectly true.

set "QC_ROOT=F:\promec\TIMSTOF\QC\DIA"
set "DUCKDB_BIN=C:\Program Files\DuckDB\duckdb.exe"
set "DB_FILE=%QC_ROOT%\diannrun.duckdb"
if not exist "%DUCKDB_BIN%" exit /b 1
if "%~1" NEQ "" set "SINGLE_RUN=%~1"
echo Starting diannrunDB: %DATE% %TIME%

:: -- Schema init -------------------------------------------------------------------
set "INIT_SQL=%QC_ROOT%\diannrunDB_init.sql"
> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS ingested_runs_dia(run_id VARCHAR PRIMARY KEY,n_precursors INTEGER,n_protein_groups INTEGER,ingested_at TIMESTAMP DEFAULT current_timestamp);
>> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS precursorsDIA(run_id VARCHAR NOT NULL,
>> "%INIT_SQL%" echo "Protein.Group" VARCHAR,
>> "%INIT_SQL%" echo "Protein.Ids" VARCHAR,
>> "%INIT_SQL%" echo "Genes" VARCHAR,
>> "%INIT_SQL%" echo "Protein.Names" VARCHAR,
>> "%INIT_SQL%" echo "Stripped.Sequence" VARCHAR,
>> "%INIT_SQL%" echo "Modified.Sequence" VARCHAR,
>> "%INIT_SQL%" echo "Precursor.Id" VARCHAR,
>> "%INIT_SQL%" echo "Precursor.Charge" INTEGER,
>> "%INIT_SQL%" echo "Proteotypic" INTEGER,
>> "%INIT_SQL%" echo "Decoy" INTEGER,
>> "%INIT_SQL%" echo "RT" DOUBLE,
>> "%INIT_SQL%" echo "Precursor.Quantity" DOUBLE,
>> "%INIT_SQL%" echo "Precursor.Normalised" DOUBLE,
>> "%INIT_SQL%" echo "PG.MaxLFQ" DOUBLE,
>> "%INIT_SQL%" echo "Genes.MaxLFQ" DOUBLE,
>> "%INIT_SQL%" echo "Q.Value" DOUBLE,
>> "%INIT_SQL%" echo "PG.Q.Value" DOUBLE,
>> "%INIT_SQL%" echo "Global.Q.Value" DOUBLE,
>> "%INIT_SQL%" echo "Global.PG.Q.Value" DOUBLE,
>> "%INIT_SQL%" echo "PEP" DOUBLE,
>> "%INIT_SQL%" echo "PG.PEP" DOUBLE,
>> "%INIT_SQL%" echo ingested_at TIMESTAMP DEFAULT current_timestamp);
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
:: File pattern: QC_ROOT\<RUN_NAME>\<RUN_NAME>.d.report.parquet
:: (the run name is embedded in the filename, unlike MaxQuant's fixed
:: "combined\txt\proteinGroups.txt" relative path)
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
>> "%SQL%" echo INSERT INTO precursorsDIA(run_id,
>> "%SQL%" echo "Protein.Group","Protein.Ids","Genes","Protein.Names",
>> "%SQL%" echo "Stripped.Sequence","Modified.Sequence","Precursor.Id","Precursor.Charge",
>> "%SQL%" echo "Proteotypic","Decoy","RT","Precursor.Quantity","Precursor.Normalised",
>> "%SQL%" echo "PG.MaxLFQ","Genes.MaxLFQ","Q.Value","PG.Q.Value","Global.Q.Value",
>> "%SQL%" echo "Global.PG.Q.Value","PEP","PG.PEP",ingested_at)
>> "%SQL%" echo SELECT '%RUN_NAME%',
>> "%SQL%" echo "Protein.Group","Protein.Ids","Genes","Protein.Names",
>> "%SQL%" echo "Stripped.Sequence","Modified.Sequence","Precursor.Id","Precursor.Charge",
>> "%SQL%" echo "Proteotypic","Decoy","RT","Precursor.Quantity","Precursor.Normalised",
>> "%SQL%" echo "PG.MaxLFQ","Genes.MaxLFQ","Q.Value","PG.Q.Value","Global.Q.Value",
>> "%SQL%" echo "Global.PG.Q.Value","PEP","PG.PEP",current_timestamp FROM _src;
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
>> "%SQL%" echo INSERT OR REPLACE INTO ingested_runs_dia VALUES('%RUN_NAME%',(SELECT COUNT(*) FROM precursorsDIA WHERE run_id='%RUN_NAME%'),(SELECT COUNT(*) FROM proteinGroupsDIA WHERE run_id='%RUN_NAME%'),current_timestamp);
>> "%SQL%" echo COMMIT;
>> "%SQL%" echo COPY(SELECT n_precursors,n_protein_groups FROM ingested_runs_dia WHERE run_id='%RUN_NAME%')TO '%SQL%.csv'(FORMAT CSV,HEADER false);

"%DUCKDB_BIN%" "%DB_FILE%" -f "%SQL%"
set "EX=%ERRORLEVEL%"
set "RC=0 0"
if exist "%SQL%.csv" for /f "usebackq delims=" %%R in ("%SQL%.csv") do set "RC=%%R"
del "%SQL%" "%SQL%.csv" 2>nul
if "%EX%" NEQ "0" (echo %DATE% %TIME% ERROR %RUN_NAME% & endlocal & exit /b 1)
echo %DATE% %TIME% DONE %RUN_NAME% (!RC! = precursors,protein_groups)
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

:: -------------------------------------------------------------------------------------
:: VERIFICATION QUERY -- run this once after a few runs are ingested to confirm
:: the "PG.MaxLFQ / PG.Q.Value constant per (run, Protein.Group)" assumption:
::
:: SELECT run_id, "Protein.Group", COUNT(DISTINCT "PG.MaxLFQ") AS distinct_lfq
:: FROM precursorsDIA GROUP BY run_id, "Protein.Group"
:: HAVING COUNT(DISTINCT "PG.MaxLFQ") > 1;
::
:: Should return ZERO rows. If it doesn't, the MAX() aggregation in
:: proteinGroupsDIA is silently picking one of several differing values --
:: worth investigating which DIA-NN setting causes the variance.
:: -------------------------------------------------------------------------------------
