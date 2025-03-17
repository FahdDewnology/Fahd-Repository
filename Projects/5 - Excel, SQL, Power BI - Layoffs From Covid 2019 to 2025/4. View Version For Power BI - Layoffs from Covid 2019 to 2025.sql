# Exploratory Analysis - Layoffs from Covid 2019 to Present

select *
from world_layoffs.layoffs_staging_2;

# 1. Companies with the highest to lowest layoffs as total
create view Companies_Total_Layoffs as
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by sum(total_laid_off) desc;

# 2. Locations with the highest to lowest layoffs as total
create view Location_Total_Layoffs as
select location, sum(total_laid_off)
from layoffs_staging_2
group by location
order by sum(total_laid_off) desc;

# 3. Industry with the highest to lowest layoffs as total
create view Industry_Total_Layoffs as
select industry, sum(total_laid_off)
from layoffs_staging_2
group by industry
order by sum(total_laid_off) desc;

# 4. Stage with the highest to lowest layoffs as total
create view Stage_Total_Layoffs as
select stage, sum(total_laid_off)
from layoffs_staging_2
group by stage
order by sum(total_laid_off) desc;

# 5. Country with the highest to lowest layoffs as total
create view Country_Total_Layoffs as
select country, sum(total_laid_off)
from layoffs_staging_2
group by country
order by sum(total_laid_off) desc;

# 6. Top 10 Companies with the highest layoffs from Covid 2019 to Present
create view Top_10_Companies_Highest_Layoffs as
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by sum(total_laid_off) desc
limit 10;
    
# 7. Top 10 Companies with the least layoffs from Covid 2019 to Present
create view Top_10_Companies_Least_Layoffs as
select company, sum(total_laid_off)
from layoffs_staging_2
where total_laid_off is not null
group by company
order by sum(total_laid_off) asc
limit 10;
    
# 8. Companies which went under i.e percentage_laid_off = 1 which is 100% of the company
create view Companies_which_went_under as
select company
from layoffs_staging_2
where percentage_laid_off = 1;

# 9. Companies which went under i.e percentage_laid_off = 1 which is 100% of the company along with total_laid_off
create view Companies_which_went_under_with_total_laid_off as
select company, sum(total_laid_off)
from layoffs_staging_2
where percentage_laid_off = 1 and total_laid_off is not null
group by company
order by sum(total_laid_off) desc;

# 10. when did layoffs start due to the pandemic as per the dataset
create view layoffs_date_range as
select min(`date`), max(`date`)
from layoffs_staging_2;

# 11. date based lay offs
create view layoffs_based_on_date as
select `date`, sum(total_laid_off)
from layoffs_staging_2
group by `date`
order by 1 desc;

# 12. year based lay offs
create view layoffs_based_on_year as
select year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by year(`date`)
order by 1 asc;

# 13. quarter based lay offs
create view layoffs_based_on_quarter as
select quarter(`date`), sum(total_laid_off)
from layoffs_staging_2
group by quarter(`date`)
order by 1 asc;

# 14. quarter and year based lay offs
create view layoffs_based_on_quarter_and_year as
select year(`date`) as year, quarter(`date`) as quarter, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), quarter(`date`)
order by year asc, quarter asc;

# 15. month and year based lay offs
create view layoffs_based_on_month_and_year as
select year(`date`) as year, month(`date`) as month, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), month(`date`)
order by year asc, month asc;

# 16. rolling total of month and year based layoffs
create view rolling_total_of_layoffs_based_on_month_and_year as
with rolling_total as
(
select year(`date`) as year, month(`date`) as month, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
group by year(`date`), month(`date`)
order by year asc, month asc
)

select year, month, total_laid_off, sum(total_laid_off) over(order by year, month) as rolling_total_layoff
from rolling_total;

# 17. rolling sum of month & year combined vs lay off
create view rolling_total_of_layoffs_based_on_month_and_year_combined as
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

# 18. doing a dense ranking and finding which company laidoff the most in that particular year
create view dense_ranking_of_layoffs_based_on_year as
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

# 19. dense ranking till the limit 5
create view Top_5_dense_ranking_of_layoffs_based_on_year
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

# 20. Company with the highest to lowest funds raised
create view highest_to_lowest_funds_of_companies as
select company, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by company
order by funds_raised_in_millions desc;

# 21. Industry with the highest to lowest funds raised
create view highest_to_lowest_funds_of_industries as
select industry, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by industry
order by funds_raised_in_millions desc;

# 22. Location with the highest to lowest funds raised
create view highest_to_lowest_funds_of_locations as
select location, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by location
order by funds_raised_in_millions desc;

# 23. Country with the highest to lowest funds raised
create view highest_to_lowest_funds_of_countries as
select country, sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by country
order by funds_raised_in_millions desc;

# 24. Comparing companies with total_laid_off and funds_raised_in_millions
create view companies_total_laidoff_vs_funds_raised as
select company, sum(total_laid_off), sum(funds_raised_in_millions) as funds_raised_in_millions
from layoffs_staging_2
group by company
order by funds_raised_in_millions desc;

# 25. industries with different average percentage laid off
create view companies_vs_avg_percentage_laid_off as
select industry, avg(percentage_laid_off) as avg_laid_off_pct  
from layoffs_staging_2  
group by industry  
order by avg_laid_off_pct desc;

# 26. companies that raised more than $100m
create view companies_of_funds_raised_over_100m as
select company, funds_raised_in_millions  
from layoffs_staging_2  
where funds_raised_in_millions > 100;

# 27. layoffs by company stages
create view layoffs_based_on_company_stages as
select stage, sum(total_laid_off) as total_laid_offs  
from layoffs_staging_2  
group by stage  
order by total_laid_offs desc;

# 28. highest layoff in a single month
create view highest_layoffs_in_1_month as
select year(`date`) as year, month(`date`) as month, sum(total_laid_off)
from layoffs_staging_2
group by month, year
order by sum(total_laid_off) desc
limit 1;

# 29. avg funds raised based on industry
create view avg_funds_raised_based_on_industry as
select industry, avg(funds_raised_in_millions) as avg_funds_raised
from layoffs_staging_2
group by industry
order by avg_funds_raised desc;

# 30. companies with layoffs but no funds raised
create view companies_with_layoffs_but_no_funds_raised as
select company, total_laid_off, funds_raised_in_millions  
from layoffs_staging_2  
where funds_raised_in_millions is null  
order by total_laid_off desc;

# 31. companies which laid off more than 50% of their workforce
create view companies_with_more_than_50_percent_layoffs as
select company, sum(total_laid_off) as total_laid_off, avg(percentage_laid_off) as avg_percentage_laid_off  
from layoffs_staging_2  
where percentage_laid_off > 0.50
group by company  
order by total_laid_off desc;

# Location - Layoffs Vs Funds Raised
create view location_layoffs_funds as
select location, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by location
order by sum(total_laid_off) desc;

# Country - Layoffs Vs Funds Raised
create view country_layoffs_funds as
select country, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by country
order by sum(total_laid_off) desc;

# Industry - Layoffs Vs Funds Raised
create view industry_layoffs_funds as
select industry, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by industry
order by sum(total_laid_off) desc;

# Stage - Layoffs Vs Funds Raised
create view stage_layoffs_funds as
select stage, sum(total_laid_off), sum(funds_raised_in_millions)
from layoffs_staging_2
group by stage
order by sum(total_laid_off) desc;

# 32. Full Table
create view full_table as
select max(`date`)
from layoffs_staging_2;

# Top 10 Companies with the least layoffs from Covid 2019 to Present
create view top_10_companies_least_layoffs_asc as
select company, sum(total_laid_off)
from layoffs_staging_2
where total_laid_off is not null
group by company
order by sum(total_laid_off) asc
limit 10;

# Query to call the tables
SHOW FULL TABLES WHERE Table_type = 'VIEW';