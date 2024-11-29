-- Data Cleaning


SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Strandardize
-- 3. Null values or blank values
-- 4. Remove Any Columns or Rows



CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT 
    *, 
    ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, date ORDER BY date) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT 
    *, 
    ROW_NUMBER() OVER (PARTITION BY company, location,
    industry, total_laid_off, percentage_laid_off, date ORDER BY date, stage
    , country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT 
    *, 
    ROW_NUMBER() OVER (PARTITION BY company, location,
    industry, total_laid_off, percentage_laid_off, date ORDER BY date, stage
    , country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
   `company` TEXT,
   `location` TEXT,
   `industry` TEXT,
   `total_laid_off` INT DEFAULT NULL,
   `percentage_laid_off` TEXT,
   `date` TEXT,
   `stage` TEXT,
   `country` TEXT,
   `funds_raised_millions` INT DEFAULT NULL,
   `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;



INSERT INTO layoffs_staging2
SELECT *,
 ROW_NUMBER() OVER (PARTITION BY company, location,
    industry, total_laid_off, percentage_laid_off, date ORDER BY date, stage
    , country, funds_raised_millions) AS row_num
FROM layoffs_staging;



SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET company = TRIM(company)
WHERE company IS NOT NULL;

SELECT DISTINCT industry
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '' ;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


SELECT location
FROM layoffs_staging2;

SELECT DISTINCT location, country
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Mal%'; 

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'Mal%';

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Flor%';

UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE location LIKE 'Flor%';

SELECT *
FROM layoffs_staging2
WHERE location LIKE '%sseldorf'; 

UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location LIKE '%sseldorf';

SELECT t1 industry, t2 industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NULL;

UPDATE 
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

DELETE FROM layoffs_staging2
WHERE company = 'Airbnb' AND industry IS NULL;

SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

DELETE FROM layoffs_staging2
WHERE company = 'Airbnb' AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;