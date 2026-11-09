-- Exploratory Data Analysis · MySQL 8.0+
-- Input: layoffs_staging2 (created by sql/Data Cleaning.sql)

-- 1. Dataset coverage and volume
SELECT
    COUNT(*) AS records,
    MIN(`date`) AS first_record_date,
    MAX(`date`) AS last_record_date,
    COUNT(DISTINCT company) AS companies,
    COUNT(DISTINCT country) AS countries
FROM layoffs_staging2;

-- 2. Records where the full reported workforce was laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 3. Total reported layoffs by company
SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;

-- 4. Total reported layoffs by country
SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- 5. Total reported layoffs by industry
SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 6. Total reported layoffs by funding stage
SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- 7. Annual trend
-- Group by YEAR(date), not the full date, so each year is one result row.
SELECT
    YEAR(`date`) AS `year`,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY `year`;

-- 8. Average reported layoff percentage by company.
-- Percentages are not additive; AVG is used instead of SUM.
SELECT
    company,
    ROUND(AVG(percentage_laid_off) * 100, 2) AS avg_layoff_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY avg_layoff_percentage DESC;

-- 9. Monthly layoffs
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS `month`,
    SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY `month`;

-- 10. Monthly layoffs with a cumulative rolling total
WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS `month`,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT
    `month`,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER (
        ORDER BY `month`
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_total_layoffs
FROM monthly_totals
ORDER BY `month`;

-- 11. Company-year totals
SELECT
    company,
    YEAR(`date`) AS `year`,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY company, YEAR(`date`)
ORDER BY `year`, total_layoffs DESC;

-- 12. Top five companies per year.
-- DENSE_RANK keeps ties, so a year can return more than five companies.
WITH company_year AS (
    SELECT
        company,
        YEAR(`date`) AS `year`,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
company_year_ranked AS (
    SELECT
        company,
        `year`,
        total_layoffs,
        DENSE_RANK() OVER (
            PARTITION BY `year`
            ORDER BY total_layoffs DESC
        ) AS ranking
    FROM company_year
    WHERE total_layoffs IS NOT NULL
)
SELECT
    company,
    `year`,
    total_layoffs,
    ranking
FROM company_year_ranked
WHERE ranking <= 5
ORDER BY `year`, ranking, company;
