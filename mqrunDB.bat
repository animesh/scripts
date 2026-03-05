@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: mqrunDB.bat  - Ingest MaxQuant proteinGroups.txt into DuckDB
:: ============================================================
::
:: Changes from original:
::
::  FIX 1 - FINAL_SQL file-existence skip guard removed.
::          Was skipping ingestion permanently if a prior run
::          crashed after writing the SQL file but before DuckDB
::          committed. Now relies solely on ingested_runs table.
::
::  FIX 2 - Path-embedded column names (Intensity D:\TMPDIR\...,
::          iBAQ D:\TMPDIR\... etc) are excluded from ingestion.
::          Schema is fixed to the 42 columns common to all runs
::          (derived from hdr.txt analysis of 107 completed jobs).
::          Avoids schema explosion and cross-run column mismatch.
::
::  FIX 3 - PG_ROWS was off by one. COUNT(*) already returns data
::          rows; subtracting 1 for the header was wrong.
::          Removed the redundant line-count step entirely.
::
::  FIX 4 - Temp SQL/CSV files cleaned up after each successful
::          ingest. Previously ~8 files per run accumulated
::          indefinitely in QC_ROOT (~1400 files for 178 runs).
::
::  FIX 5 - __stg renamed to __stg_<run> to avoid clobbering
::          if two instances ever run concurrently.
::
::  FIX 6 - Schema is fixed (42 columns). TRY_CAST used for all
::          columns so bad values become NULL rather than aborting
::          the entire ingest. No schema drift across MQ versions.
::
::  FIX 7 - RAW_FILTER was applied via !delayed! expansion inside
::          a > redirect - did not expand correctly. Filter is now
::          baked directly into the fixed SELECT clause, not needed
::          as a variable at all.
::
::  FIX 8 - ingested_runs table now stores row count for auditability.
::
:: ============================================================

set "QC_ROOT=L:\promec\TIMSTOF\QC"
set "DUCKDB_BIN=%QC_ROOT%\duckdb.exe"
set "DB_FILE=%QC_ROOT%\mqrun.duckdb"
set "PG_REL=combined\txt\proteinGroups.txt"

if not exist "%DUCKDB_BIN%" (
    echo ERROR: duckdb.exe not found at %DUCKDB_BIN%
    exit /b 1
)
if not exist "%QC_ROOT%" mkdir "%QC_ROOT%"

if "%~1" NEQ "" set "SINGLE_RUN=%~1"

echo Starting mqrunDB: %DATE% %TIME%
echo QC_ROOT  = %QC_ROOT%
echo DB_FILE  = %DB_FILE%

:: ---------------------------------------------------------------
:: Initialise DB: ingested_runs table tracks what has been loaded.
:: row_count added (FIX 8) for audit trail.
:: ---------------------------------------------------------------
set "INIT_SQL=%QC_ROOT%\mqrunDB_init.sql"
> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS ingested_runs (
>> "%INIT_SQL%" echo     run_id       VARCHAR PRIMARY KEY,
>> "%INIT_SQL%" echo     row_count    INTEGER,
>> "%INIT_SQL%" echo     ingested_at  TIMESTAMP DEFAULT current_timestamp
>> "%INIT_SQL%" echo );
>> "%INIT_SQL%" echo.
:: Fixed schema - 42 columns common to all runs (no path-embedded cols).
:: TRY_CAST: bad values become NULL, ingest never aborts on a dirty cell.
>> "%INIT_SQL%" echo CREATE TABLE IF NOT EXISTS proteinGroups (
>> "%INIT_SQL%" echo     run_id                                   VARCHAR NOT NULL,
>> "%INIT_SQL%" echo     "Protein IDs"                            VARCHAR,
>> "%INIT_SQL%" echo     "Majority protein IDs"                   VARCHAR,
>> "%INIT_SQL%" echo     "Peptide counts (all)"                   VARCHAR,
>> "%INIT_SQL%" echo     "Peptide counts (razor+unique)"          VARCHAR,
>> "%INIT_SQL%" echo     "Peptide counts (unique)"                VARCHAR,
>> "%INIT_SQL%" echo     "Protein names"                          VARCHAR,
>> "%INIT_SQL%" echo     "Gene names"                             VARCHAR,
>> "%INIT_SQL%" echo     "Fasta headers"                          VARCHAR,
>> "%INIT_SQL%" echo     "Number of proteins"                     INTEGER,
>> "%INIT_SQL%" echo     "Peptides"                               INTEGER,
>> "%INIT_SQL%" echo     "Razor + unique peptides"                INTEGER,
>> "%INIT_SQL%" echo     "Unique peptides"                        INTEGER,
>> "%INIT_SQL%" echo     "Sequence coverage [%%]"                 DOUBLE,
>> "%INIT_SQL%" echo     "Unique + razor sequence coverage [%%]"  DOUBLE,
>> "%INIT_SQL%" echo     "Unique sequence coverage [%%]"          DOUBLE,
>> "%INIT_SQL%" echo     "Mol. weight [kDa]"                      DOUBLE,
>> "%INIT_SQL%" echo     "Sequence length"                        INTEGER,
>> "%INIT_SQL%" echo     "Sequence lengths"                       VARCHAR,
>> "%INIT_SQL%" echo     "Q-value"                                DOUBLE,
>> "%INIT_SQL%" echo     "Score"                                  DOUBLE,
>> "%INIT_SQL%" echo     "Intensity"                              DOUBLE,
>> "%INIT_SQL%" echo     "iBAQ peptides"                          INTEGER,
>> "%INIT_SQL%" echo     "iBAQ"                                   DOUBLE,
>> "%INIT_SQL%" echo     "Top3"                                   DOUBLE,
>> "%INIT_SQL%" echo     "MS/MS count"                            INTEGER,
>> "%INIT_SQL%" echo     "Peptide sequences"                      VARCHAR,
>> "%INIT_SQL%" echo     "Only identified by site"                VARCHAR,
>> "%INIT_SQL%" echo     "Reverse"                                VARCHAR,
>> "%INIT_SQL%" echo     "Potential contaminant"                  VARCHAR,
>> "%INIT_SQL%" echo     "id"                                     INTEGER,
>> "%INIT_SQL%" echo     "Peptide IDs"                            VARCHAR,
>> "%INIT_SQL%" echo     "Peptide is razor"                       VARCHAR,
>> "%INIT_SQL%" echo     "Mod. peptide IDs"                       VARCHAR,
>> "%INIT_SQL%" echo     "Evidence IDs"                           VARCHAR,
>> "%INIT_SQL%" echo     "MS/MS IDs"                              VARCHAR,
>> "%INIT_SQL%" echo     "Best MS/MS"                             INTEGER,
>> "%INIT_SQL%" echo     "Deamidation (NQ) site IDs"              VARCHAR,
>> "%INIT_SQL%" echo     "Oxidation (M) site IDs"                 VARCHAR,
>> "%INIT_SQL%" echo     "Deamidation (NQ) site positions"        VARCHAR,
>> "%INIT_SQL%" echo     "Oxidation (M) site positions"           VARCHAR,
>> "%INIT_SQL%" echo     "Taxonomy IDs"                           VARCHAR,
>> "%INIT_SQL%" echo     "Taxonomy names"                         VARCHAR,
>> "%INIT_SQL%" echo     ingested_at  TIMESTAMP DEFAULT current_timestamp,
>> "%INIT_SQL%" echo     PRIMARY KEY (run_id, "id")
>> "%INIT_SQL%" echo );
"%DUCKDB_BIN%" "%DB_FILE%" -f "%INIT_SQL%" >nul 2>&1
del "%INIT_SQL%" 2>nul

:: ---------------------------------------------------------------
:: Report starting row count
:: ---------------------------------------------------------------
call :mq_db_count start

:: ---------------------------------------------------------------
:: Main ingest loop
:: ---------------------------------------------------------------
if defined SINGLE_RUN (
    set "LOOP_GLOB=%QC_ROOT%\%SINGLE_RUN%"
) else (
    set "LOOP_GLOB=%QC_ROOT%\*"
)

for /d %%P in ("%LOOP_GLOB%") do (
    call :ingest_run "%%~fP" "%%~nxP"
)

call :mq_db_count end
exit /b 0


:: ============================================================
:: :ingest_run <run_path> <run_name>
:: ============================================================
:ingest_run
setlocal EnableDelayedExpansion
set "RUN_PATH=%~1"
set "RUN_NAME=%~2"
set "PG_FILE=%RUN_PATH%\%PG_REL%"

:: Skip if no proteinGroups.txt
if not exist "%PG_FILE%" endlocal & exit /b 0

:: Skip if empty
for %%S in ("%PG_FILE%") do set "PG_SIZE=%%~zS"
if "%PG_SIZE%"=="0" (
    echo %DATE% %TIME% SKIP  %RUN_NAME%  ^(proteinGroups.txt is empty^)
    endlocal & exit /b 0
)

:: ---------------------------------------------------------------
:: FIX 1: Skip guard is solely the ingested_runs table.
:: No file-existence check - that caused permanent skips after
:: a crash mid-ingest.
:: ---------------------------------------------------------------
set "ALREADY_SQL=%QC_ROOT%\mq_check_%RUN_NAME%.sql"
set "ALREADY_OUT=%QC_ROOT%\mq_check_%RUN_NAME%.csv"
> "%ALREADY_SQL%" echo COPY (SELECT COUNT(*) FROM ingested_runs WHERE run_id = '%RUN_NAME%') TO '%ALREADY_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%ALREADY_SQL%" >nul 2>&1
set "ALREADY=0"
if exist "%ALREADY_OUT%" for /f "usebackq delims=" %%I in ("%ALREADY_OUT%") do set "ALREADY=%%I"
del "%ALREADY_SQL%" "%ALREADY_OUT%" 2>nul
if "%ALREADY%" NEQ "0" (
    echo %DATE% %TIME% SKIP  %RUN_NAME%  ^(already in DB^)
    endlocal & exit /b 0
)

echo %DATE% %TIME% START %RUN_NAME%

:: Forward slashes for DuckDB paths
set "PG_FILE_SLASH=%PG_FILE:\=/%"

:: ---------------------------------------------------------------
:: Stage into __stg_<run> (FIX 5: unique name avoids concurrency
:: clobber). read_csv_auto with explicit tab delimiter.
:: ---------------------------------------------------------------
set "STG_TABLE=__stg_%RUN_NAME%"
set "STAGE_SQL=%QC_ROOT%\mq_stage_%RUN_NAME%.sql"
> "%STAGE_SQL%" echo DROP TABLE IF EXISTS "%STG_TABLE%";
>> "%STAGE_SQL%" echo CREATE TABLE "%STG_TABLE%" AS
>> "%STAGE_SQL%" echo     SELECT * FROM read_csv_auto('%PG_FILE_SLASH%', delim=chr(9), header=true, ignore_errors=true);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%STAGE_SQL%"
del "%STAGE_SQL%" 2>nul

:: ---------------------------------------------------------------
:: FIX 3: Row count comes directly from staged table, not line
:: count minus 1. COUNT(*) already returns data rows only.
:: ---------------------------------------------------------------
set "COUNT_SQL=%QC_ROOT%\mq_count_%RUN_NAME%.sql"
set "COUNT_OUT=%QC_ROOT%\mq_count_%RUN_NAME%.csv"
> "%COUNT_SQL%" echo COPY (SELECT COUNT(*) FROM "%STG_TABLE%") TO '%COUNT_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%COUNT_SQL%" >nul 2>&1
set "PG_ROWS=0"
if exist "%COUNT_OUT%" for /f "usebackq delims=" %%N in ("%COUNT_OUT%") do set "PG_ROWS=%%N"
del "%COUNT_SQL%" "%COUNT_OUT%" 2>nul
echo %DATE% %TIME%   Staged %PG_ROWS% rows for %RUN_NAME%

if "%PG_ROWS%"=="0" (
    echo %DATE% %TIME% SKIP  %RUN_NAME%  ^(staged table is empty^)
    "%DUCKDB_BIN%" "%DB_FILE%" -c "DROP TABLE IF EXISTS ""%STG_TABLE%"";" >nul 2>&1
    endlocal & exit /b 0
)

:: ---------------------------------------------------------------
:: FIX 2 + FIX 6 + FIX 7:
:: Fixed SELECT of only the 42 common columns using TRY_CAST.
:: Path-embedded columns (Intensity D:\TMPDIR\..., iBAQ D:\TMPDIR\
:: etc) are simply not selected - no filter variable needed.
:: TRY_CAST: dirty cells become NULL, ingest never aborts.
:: ---------------------------------------------------------------
set "FINAL_SQL=%QC_ROOT%\mq_final_%RUN_NAME%.sql"
> "%FINAL_SQL%" echo BEGIN TRANSACTION;
>> "%FINAL_SQL%" echo INSERT INTO proteinGroups
>> "%FINAL_SQL%" echo SELECT
>> "%FINAL_SQL%" echo     '%RUN_NAME%'                                                          AS run_id,
>> "%FINAL_SQL%" echo     TRY_CAST("Protein IDs"                          AS VARCHAR)          AS "Protein IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Majority protein IDs"                 AS VARCHAR)          AS "Majority protein IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide counts (all)"                 AS VARCHAR)          AS "Peptide counts (all)",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide counts (razor+unique)"        AS VARCHAR)          AS "Peptide counts (razor+unique)",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide counts (unique)"              AS VARCHAR)          AS "Peptide counts (unique)",
>> "%FINAL_SQL%" echo     TRY_CAST("Protein names"                        AS VARCHAR)          AS "Protein names",
>> "%FINAL_SQL%" echo     TRY_CAST("Gene names"                           AS VARCHAR)          AS "Gene names",
>> "%FINAL_SQL%" echo     TRY_CAST("Fasta headers"                        AS VARCHAR)          AS "Fasta headers",
>> "%FINAL_SQL%" echo     TRY_CAST("Number of proteins"                   AS INTEGER)          AS "Number of proteins",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptides"                             AS INTEGER)          AS "Peptides",
>> "%FINAL_SQL%" echo     TRY_CAST("Razor + unique peptides"              AS INTEGER)          AS "Razor + unique peptides",
>> "%FINAL_SQL%" echo     TRY_CAST("Unique peptides"                      AS INTEGER)          AS "Unique peptides",
>> "%FINAL_SQL%" echo     TRY_CAST("Sequence coverage [%%]"               AS DOUBLE)           AS "Sequence coverage [%%]",
>> "%FINAL_SQL%" echo     TRY_CAST("Unique + razor sequence coverage [%%]" AS DOUBLE)          AS "Unique + razor sequence coverage [%%]",
>> "%FINAL_SQL%" echo     TRY_CAST("Unique sequence coverage [%%]"        AS DOUBLE)           AS "Unique sequence coverage [%%]",
>> "%FINAL_SQL%" echo     TRY_CAST("Mol. weight [kDa]"                    AS DOUBLE)           AS "Mol. weight [kDa]",
>> "%FINAL_SQL%" echo     TRY_CAST("Sequence length"                      AS INTEGER)          AS "Sequence length",
>> "%FINAL_SQL%" echo     TRY_CAST("Sequence lengths"                     AS VARCHAR)          AS "Sequence lengths",
>> "%FINAL_SQL%" echo     TRY_CAST("Q-value"                              AS DOUBLE)           AS "Q-value",
>> "%FINAL_SQL%" echo     TRY_CAST("Score"                                AS DOUBLE)           AS "Score",
>> "%FINAL_SQL%" echo     TRY_CAST("Intensity"                            AS DOUBLE)           AS "Intensity",
>> "%FINAL_SQL%" echo     TRY_CAST("iBAQ peptides"                        AS INTEGER)          AS "iBAQ peptides",
>> "%FINAL_SQL%" echo     TRY_CAST("iBAQ"                                 AS DOUBLE)           AS "iBAQ",
>> "%FINAL_SQL%" echo     TRY_CAST("Top3"                                 AS DOUBLE)           AS "Top3",
>> "%FINAL_SQL%" echo     TRY_CAST("MS/MS count"                          AS INTEGER)          AS "MS/MS count",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide sequences"                    AS VARCHAR)          AS "Peptide sequences",
>> "%FINAL_SQL%" echo     TRY_CAST("Only identified by site"              AS VARCHAR)          AS "Only identified by site",
>> "%FINAL_SQL%" echo     TRY_CAST("Reverse"                              AS VARCHAR)          AS "Reverse",
>> "%FINAL_SQL%" echo     TRY_CAST("Potential contaminant"                AS VARCHAR)          AS "Potential contaminant",
>> "%FINAL_SQL%" echo     TRY_CAST("id"                                   AS INTEGER)          AS "id",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide IDs"                          AS VARCHAR)          AS "Peptide IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Peptide is razor"                     AS VARCHAR)          AS "Peptide is razor",
>> "%FINAL_SQL%" echo     TRY_CAST("Mod. peptide IDs"                     AS VARCHAR)          AS "Mod. peptide IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Evidence IDs"                         AS VARCHAR)          AS "Evidence IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("MS/MS IDs"                            AS VARCHAR)          AS "MS/MS IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Best MS/MS"                           AS INTEGER)          AS "Best MS/MS",
>> "%FINAL_SQL%" echo     TRY_CAST("Deamidation (NQ) site IDs"            AS VARCHAR)          AS "Deamidation (NQ) site IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Oxidation (M) site IDs"               AS VARCHAR)          AS "Oxidation (M) site IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Deamidation (NQ) site positions"      AS VARCHAR)          AS "Deamidation (NQ) site positions",
>> "%FINAL_SQL%" echo     TRY_CAST("Oxidation (M) site positions"         AS VARCHAR)          AS "Oxidation (M) site positions",
>> "%FINAL_SQL%" echo     TRY_CAST("Taxonomy IDs"                         AS VARCHAR)          AS "Taxonomy IDs",
>> "%FINAL_SQL%" echo     TRY_CAST("Taxonomy names"                       AS VARCHAR)          AS "Taxonomy names",
>> "%FINAL_SQL%" echo     current_timestamp                                                     AS ingested_at
>> "%FINAL_SQL%" echo FROM "%STG_TABLE%";
>> "%FINAL_SQL%" echo INSERT OR REPLACE INTO ingested_runs(run_id, row_count, ingested_at)
>> "%FINAL_SQL%" echo     VALUES ('%RUN_NAME%', %PG_ROWS%, current_timestamp);
>> "%FINAL_SQL%" echo DROP TABLE IF EXISTS "%STG_TABLE%";
>> "%FINAL_SQL%" echo COMMIT;

call :mq_db_count %RUN_NAME%_before
"%DUCKDB_BIN%" "%DB_FILE%" -f "%FINAL_SQL%"
set "DB_EXIT=%ERRORLEVEL%"
call :mq_db_count %RUN_NAME%_after

:: FIX 4: Clean up all temp files after ingest
del "%FINAL_SQL%" 2>nul
del "%QC_ROOT%\mq_db_count_%RUN_NAME%_before.csv" 2>nul
del "%QC_ROOT%\mq_db_count_%RUN_NAME%_after.csv"  2>nul

if "%DB_EXIT%" NEQ "0" (
    echo %DATE% %TIME% ERROR %RUN_NAME%  ^(DuckDB exited with %DB_EXIT%^)
    endlocal & exit /b 1
)

echo %DATE% %TIME% DONE  %RUN_NAME%  ^(%PG_ROWS% rows^)
endlocal & exit /b 0


:: ============================================================
:: :mq_db_count <label>  - print current proteinGroups row count
:: ============================================================
:mq_db_count
setlocal
set "SUF=%~1"
set "DB_COUNT_SQL=%QC_ROOT%\mq_db_count_%SUF%.sql"
set "DB_COUNT_OUT=%QC_ROOT%\mq_db_count_%SUF%.csv"
> "%DB_COUNT_SQL%" echo COPY (
>> "%DB_COUNT_SQL%" echo     SELECT CASE
>> "%DB_COUNT_SQL%" echo         WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='proteinGroups')
>> "%DB_COUNT_SQL%" echo         THEN (SELECT COUNT(*) FROM proteinGroups)
>> "%DB_COUNT_SQL%" echo         ELSE 0
>> "%DB_COUNT_SQL%" echo     END
>> "%DB_COUNT_SQL%" echo ) TO '%DB_COUNT_OUT%' (FORMAT CSV, HEADER false);
"%DUCKDB_BIN%" "%DB_FILE%" -f "%DB_COUNT_SQL%" >nul 2>&1
set "DB_RET=0"
if exist "%DB_COUNT_OUT%" for /f "usebackq delims=" %%R in ("%DB_COUNT_OUT%") do set "DB_RET=%%R"
del "%DB_COUNT_SQL%" "%DB_COUNT_OUT%" 2>nul
echo %DATE% %TIME%   DB rows [%SUF%]: %DB_RET%
endlocal & exit /b 0
