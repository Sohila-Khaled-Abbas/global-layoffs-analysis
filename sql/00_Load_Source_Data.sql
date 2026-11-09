-- 00 · Load the repository's layoffs CSV into a MySQL source table
-- Requires MySQL 8.0+ and LOCAL INFILE enabled in both client and server.
--
-- IMPORTANT:
-- 1. Change the absolute path below to the location of data/layoffs-cleaned.csv.
-- 2. This script drops and recreates ONLY the dedicated layoffs_source table.
-- 3. The repository extract contains 3,984 data rows, including exact repeated
--    records. Duplicate handling is performed later in Data Cleaning.sql.
-- 4. The file name says "cleaned", but this extract still needs duplicate and
--    data-quality handling before it is used for analysis.

SHOW VARIABLES LIKE 'local_infile';

DROP TABLE IF EXISTS layoffs_source;

CREATE TABLE layoffs_source (
    company              TEXT NULL,
    location             TEXT NULL,
    industry              TEXT NULL,
    total_laid_off        INT NULL,
    percentage_laid_off   DECIMAL(8, 4) NULL,
    `date`                VARCHAR(32) NULL,
    stage                 VARCHAR(100) NULL,
    country               VARCHAR(100) NULL,
    funds_raised_millions DECIMAL(14, 2) NULL
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

LOAD DATA LOCAL INFILE
    'C:/absolute/path/to/global-layoffs-analysis/data/layoffs-cleaned.csv'
INTO TABLE layoffs_source
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @company,
    @location,
    @industry,
    @total_laid_off,
    @percentage_laid_off,
    @date,
    @stage,
    @country,
    @funds_raised_millions
)
SET
    company = NULLIF(NULLIF(TRIM(@company), ''), 'NULL'),
    location = NULLIF(NULLIF(TRIM(@location), ''), 'NULL'),
    industry = NULLIF(NULLIF(TRIM(@industry), ''), 'NULL'),
    total_laid_off = CAST(
        NULLIF(NULLIF(TRIM(@total_laid_off), ''), 'NULL') AS UNSIGNED
    ),
    percentage_laid_off = CAST(
        NULLIF(NULLIF(TRIM(@percentage_laid_off), ''), 'NULL') AS DECIMAL(8, 4)
    ),
    `date` = NULLIF(NULLIF(TRIM(@date), ''), 'NULL'),
    stage = NULLIF(NULLIF(TRIM(@stage), ''), 'NULL'),
    country = NULLIF(NULLIF(TRIM(@country), ''), 'NULL'),
    funds_raised_millions = CAST(
        NULLIF(NULLIF(TRIM(@funds_raised_millions), ''), 'NULL') AS DECIMAL(14, 2)
    );

-- Import verification
SELECT
    COUNT(*) AS imported_rows,
    MIN(STR_TO_DATE(`date`, '%c/%e/%Y')) AS earliest_layoff_date,
    MAX(STR_TO_DATE(`date`, '%c/%e/%Y')) AS latest_layoff_date
FROM layoffs_source;

SELECT *
FROM layoffs_source
LIMIT 10;
