# Exploratory Data Analysis

select *
from layoffs_staging_2;

# looking at max total_laid_off and percentage_laid_off

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging_2;

# which company had a laid_off of 12000 people
select * 
from layoffs_staging_2
where total_laid_off = 12000;

# Company which went under
select * 
from layoffs_staging_2
where percentage_laid_off = 1;

# Company which went under order by amount of people laid_off
select * 
from layoffs_staging_2
where percentage_laid_off = 1
order by total_laid_off desc;

# Company which went under that had highest to lowest fundings
select * 
from layoffs_staging_2
where percentage_laid_off = 1
order by funds_raised_millions desc;

# All layoffs by companies
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by 2 desc;

# when did layoffs start due to the pandamic as per the dataset
select min(`date`), max(`date`)
from layoffs_staging_2;

# industry with the highest to lowest lay offs
select industry, sum(total_laid_off)
from layoffs_staging_2
group by industry
order by 2 desc;

# country with the highest to lowest lay offs
select country, sum(total_laid_off)
from layoffs_staging_2
group by country
order by 2 desc;

# date based lay offs
select `date`, sum(total_laid_off)
from layoffs_staging_2
group by `date`
order by 1 desc;

# year based lay offs
select year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by year(`date`)
order by 1 desc;

# stage with the highest to lowest lay offs
select stage, sum(total_laid_off)
from layoffs_staging_2
group by stage
order by 2 desc;

# rolling sum of month & year vs lay off

select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_layoff
from layoffs_staging_2
where substring(`date`,1,7) is not null
group by `month`
order by `month`;

with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_layoff
from layoffs_staging_2
where substring(`date`,1,7) is not null
group by `month`
order by `month`
)

select `month`, total_layoff, sum(total_layoff) over(order by `month`) rolling_total_layoff
from rolling_total;

# layoffs based on company and year

select company, year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by company, year(`date`)
order by company;

# doing a dense ranking and finding which company laidoff the most in that particular year

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by company, year(`date`)
)

select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking asc;

# same thing but only till the ranking of 5

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by company, year(`date`)
)
, company_year_rank as 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from company_year_rank
where ranking <= 5;
