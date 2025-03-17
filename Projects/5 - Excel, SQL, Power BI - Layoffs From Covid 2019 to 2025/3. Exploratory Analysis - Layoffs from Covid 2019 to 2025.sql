# Exploratory Analysis - Layoffs from Covid 2019 to Present

select *
from world_layoffs.layoffs_staging_2;

# Companies with the highest to lowest layoffs as total
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by sum(total_laid_off) desc;

# Locations with the highest to lowest layoffs as total
select location, sum(total_laid_off)
from layoffs_staging_2
group by location
order by sum(total_laid_off) desc;

# Industry with the highest to lowest layoffs as total
select industry, sum(total_laid_off)
from layoffs_staging_2
group by industry
order by sum(total_laid_off) desc;

# Stage with the highest to lowest layoffs as total
select stage, sum(total_laid_off)
from layoffs_staging_2
group by stage
order by sum(total_laid_off) desc;

# Country with the highest to lowest layoffs as total
select country, sum(total_laid_off)
from layoffs_staging_2
group by country
order by sum(total_laid_off) desc;

SHOW FULL TABLES WHERE Table_type = 'VIEW';

# Top 10 Companies with the highest layoffs from Covid 2019 to Present
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by sum(total_laid_off) desc
limit 10;
    
# Top 10 Companies with the least layoffs from Covid 2019 to Present
select company, sum(total_laid_off)
from layoffs_staging_2
where total_laid_off is not null
group by company
order by sum(total_laid_off) asc
limit 10;
    
# Companies which went under i.e percentage_laid_off = 1 which is 100% of the company
select company
from layoffs_staging_2
where percentage_laid_off = 1;

# Companies which went under i.e percentage_laid_off = 1 which is 100% of the company along with total_laid_off
select company, sum(total_laid_off)
from layoffs_staging_2
where percentage_laid_off = 1 and total_laid_off is not null
group by company
order by sum(total_laid_off) desc;

# when did layoffs start due to the pandamic as per the dataset
select min(`date`), max(`date`)
from layoffs_staging_2;

# date based lay offs
select `date`, sum(total_laid_off)
from layoffs_staging_2
group by `date`
order by 1 desc;

# year based lay offs
select year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by year(`date`)
order by 1 asc;

# quarter based lay offs
select quarter(`date`), sum(total_laid_off)
from layoffs_staging_2
group by quarter(`date`)
order by 1 asc;

# quarter and year based lay offs
select year(`date`) as year, quarter(`date`) as quarter, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), quarter(`date`)
order by year asc, quarter asc;

# month and year based lay offs
select year(`date`) as year, month(`date`) as month, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), month(`date`)
order by year asc, month asc;

# rolling total of month and year based layoffs
with rolling_total as
(
select year(`date`) as year, month(`date`) as month, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), month(`date`)
order by year asc, month asc
)

select year, month, total_laid_off, sum(total_laid_off) over(order by year, month) as rolling_total_layoff
from rolling_total;

# rolling sum of month & year combined vs lay off
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

# dense ranking till the limit 5
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

# Company with the highest to lowest funds raised
select company, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by company
order by funds_raised_in_millions desc;

# Industry with the highest to lowest funds raised
select industry, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by industry
order by funds_raised_in_millions desc;

# Location with the highest to lowest funds raised
select location, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by location
order by funds_raised_in_millions desc;

# Country with the highest to lowest funds raised
select country, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by country
order by funds_raised_in_millions desc;

# Comparing companies with total_laid_off and funds_raised_in_millions
select company, sum(total_laid_off), sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by company
order by funds_raised_in_millions desc;

# industries with different average percentage laid off
select industry, avg(percentage_laid_off) as avg_laid_off_pct  
from layoffs_staging_2  
group by industry  
order by avg_laid_off_pct desc;

# companies that raised more than $100m
select company, funds_raised_in_millions  
from layoffs_staging_2  
where funds_raised_in_millions > 100;

# layoffs by company stage
select stage, sum(total_laid_off) as total_laid_offs  
from layoffs_staging_2  
group by stage  
order by total_laid_offs desc;

# highest layoff in a single month
select year(`date`) as year, month(`date`) as month, sum(total_laid_off)
from layoffs_staging_2
group by month, year
order by sum(total_laid_off) desc
limit 1;

# avg funds raised based on industry
select industry, avg(funds_raised_in_millions) as avg_funds_raised
from layoffs_staging_2
group by industry
order by avg_funds_raised desc;

# funds raised based on industry
select industry, sum(funds_raised_in_millions) as funds_raised
from layoffs_staging_2
group by industry
order by funds_raised desc;

# companies with layoffs but no funds raised
select company, total_laid_off, funds_raised_in_millions  
from layoffs_staging_2  
where funds_raised_in_millions is null  
order by total_laid_off desc;

# companies which laid off more than 50% of their workforce
select company, sum(total_laid_off) as total_laid_off, avg(percentage_laid_off) as avg_percentage_laid_off  
from layoffs_staging_2  
where percentage_laid_off > 0.50  
group by company  
order by total_laid_off desc;

# Location - Layoffs Vs Funds Raised
select location, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by location
order by sum(total_laid_off) desc;

# Country - Layoffs Vs Funds Raised
select country, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by country
order by sum(total_laid_off) desc;

# Industry - Layoffs Vs Funds Raised
select industry, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by industry
order by sum(total_laid_off) desc;

# Stage - Layoffs Vs Funds Raised
select stage, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by stage
order by sum(total_laid_off) desc;

# Full Table
select *
from layoffs_staging_2;