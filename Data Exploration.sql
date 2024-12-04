SELECT *
FROM layoffs_staging2;

-- The 2 most informative columns were total_laid_off (the number of employees affected in each layoff campaign), and percentage_laid_off (% of the total workforce impacted in each campaign)

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

SELECT COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off=1;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND percentage_laid_off<1
ORDER BY percentage_laid_off DESC;

SELECT SUBSTRING(`date`, 1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

-- Used a CTE to be able to do a monthly rolling total

WITH rolling_total AS
(SELECT SUBSTRING(`date`, 1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Used 2 CTEs to do a ranking of top 5 companies conducting layoffs per year (in absolute figures)

WITH company_year (company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)),
Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL)
SELECT *
FROM Company_Year_Rank
WHERE ranking<=5;

-- With the above result mentioning big companies for the most part, I wanted to put it into perspective by checking what company stages laid off a large part (or entirety) of their employees

SELECT stage, ROUND(AVG(percentage_laid_off),2)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
