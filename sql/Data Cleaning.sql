-- Data Cleaning · MySQL 8.0+
-- Source: layoffs_source (created by sql/00_Load_Source_Data.sql)
-- Output: layoffs_staging2
--
-- The source table is preserved. This script recreates only the derived
-- staging tables, so it can be rerun after reloading the source extract.

DROP TABLE IF EXISTS
    layoffs_staging2,
    layoffs_staging_normalized,
    layoffs_staging,
    company_industry_lookup;

-- 1. Preserve the imported source in a working staging table.
CREATE TABLE layoffs_staging LIKE layoffs_source;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs_source;

-- 2. Normalize text, numeric fields, and date values before deduplication.
CREATE TABLE layoffs_staging_normalized AS
SELECT
    NULLIF(TRIM(company), '') AS company,
    NULLIF(TRIM(location), '') AS location,
    NULLIF(TRIM(industry), '') AS industry,
    total_laid_off,
    percentage_laid_off,
    CASE
        WHEN TRIM(`date`) REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(`date`), '%c/%e/%Y')
        WHEN TRIM(`date`) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(`date`), '%Y-%m-%d')
        ELSE NULL
    END AS `date`,
    NULLIF(TRIM(stage), '') AS stage,
    NULLIF(TRIM(country), '') AS country,
    funds_raised_millions
FROM layoffs_staging;

-- 3. Harmonize only the crypto industry labels that are present in this
--    repository's extract: "Crypto Currency" and "CryptoCurrency".
--    Blank or missing industries are NOT assumed to be Crypto.
UPDATE layoffs_staging_normalized
SET industry = 'Crypto'
WHERE LOWER(REPLACE(TRIM(industry), ' ', '')) = 'cryptocurrency';

-- Standardize trailing punctuation in country labels without changing
-- unrelated country names.
UPDATE layoffs_staging_normalized
SET country = TRIM(TRAILING '.' FROM TRIM(country))
WHERE country IS NOT NULL;

-- 4. Fill an unknown company industry only when every known record for that
--    company agrees on exactly one non-null industry. Conflicting companies
--    remain NULL for review instead of receiving an arbitrary value.
DROP TABLE IF EXISTS company_industry_lookup;

CREATE TABLE company_industry_lookup AS
SELECT
    company,
    MIN(industry) AS resolved_industry
FROM layoffs_staging_normalized
WHERE industry IS NOT NULL
GROUP BY company
HAVING COUNT(DISTINCT industry) = 1;

UPDATE layoffs_staging_normalized AS target
JOIN company_industry_lookup AS resolved
    ON resolved.company = target.company
SET target.industry = resolved.resolved_industry
WHERE target.industry IS NULL;

DROP TABLE company_industry_lookup;

-- 5. Remove repeated business records using the same identifying fields
--    throughout the project. When duplicates differ in secondary metadata,
--    retain a deterministic row ordered by stage, country, and funding.
--    Records with both layoff measures missing are excluded from the final
--    analytical table; records with either measure available are retained.
CREATE TABLE layoffs_staging2 AS
SELECT
    ranked.company,
    ranked.location,
    ranked.industry,
    ranked.total_laid_off,
    ranked.percentage_laid_off,
    ranked.`date`,
    ranked.stage,
    ranked.country,
    ranked.funds_raised_millions
FROM (
    SELECT
        normalized.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`
            ORDER BY
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging_normalized AS normalized
) AS ranked
WHERE ranked.row_num = 1
  AND (
      ranked.total_laid_off IS NOT NULL
      OR ranked.percentage_laid_off IS NOT NULL
  );

-- 6. Quality checks
SELECT
    (SELECT COUNT(*) FROM layoffs_source) AS source_rows,
    (SELECT COUNT(*) FROM layoffs_staging2) AS cleaned_rows,
    (SELECT COUNT(*) FROM layoffs_staging2
        WHERE industry IS NULL) AS unresolved_industry_rows,
    (SELECT COUNT(*) FROM layoffs_staging2
        WHERE `date` IS NULL) AS rows_without_valid_date;

-- The following query should return zero rows if the selected business key
-- is unique after deduplication.
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`
HAVING COUNT(*) > 1;

-- Review unresolved industries without deleting their records.
SELECT
    company,
    location,
    country,
    `date`
FROM layoffs_staging2
WHERE industry IS NULL
ORDER BY company, `date`;

-- Review rows with only one of the two layoff measures available.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL
ORDER BY `date`, company;
