# Creating a new schema 
CREATE SCHEMA `world_layoffs` ;

# Importing the data set
select *
from layoffs;

# Creating a staging data to work on and seperating it from the original raw data
create table layoffs_staging
like layoffs;

# Insert the original raw data to the staging
insert layoffs_staging
select *
from layoffs;

# Checking the table
select *
from layoffs_staging;

# Removing duplicates
# Checking for repeating rows of data
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging;

# Setting it as a CTE and checking for duplicates
with duplicate_counter_cte as 
(
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging
)

select *
from duplicate_counter_cte
where count_duplicates > 1;

# Checking one of the duplicates
select *
from layoffs_staging
where company = 'Casper';

# Creating another staging table to delete the repeated rows as we can't delete rows from a CTE
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `count_duplicates` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Insert the CTE created data into the new staging table
insert into layoffs_staging_2
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging;

# Checking the new table with the duplicate count
select *
from layoffs_staging_2;

# Checking the duplicates
select *
from layoffs_staging_2
where count_duplicates > 1
;

# Deleting the duplicates
delete
from layoffs_staging_2
where count_duplicates > 1
;

# Standardizing data
# Having a general look to understand where to standardize
select *
from layoffs_staging_2;

# Using trim at company to remove any unwanted empty spaces in text
select company, trim(company)
from layoffs_staging_2;

# Updating the trim to the 2nd staging table
update layoffs_staging_2
set company = trim(company);

# Checking
select *
from layoffs_staging_2;

# Lets look at industry
select distinct industry
from layoffs_staging_2
order by 1;

# We have some blank, nulls and repeating words or different but same addressed words like Crypto
select *
from layoffs_staging_2
where industry like 'Crypto%';

# Lets update the various version of crypot to it into single type
update layoffs_staging_2
set industry = 'Crypto'
where industry like 'Crypto%';

# Checking
select *
from layoffs_staging_2
where industry like 'Crypto%';

select distinct industry
from layoffs_staging_2
order by 1;

# Lets look at location and then country
select distinct location
from layoffs_staging_2
order by 1;

select distinct country
from layoffs_staging_2
order by 1;

# There are some language variations in locations 
# United States has a . which can be fixed

# Checking
select *
from layoffs_staging_2
where country like 'United States%';

# Triming the trailing .
select distinct country, trim(trailing '.' from country)
from layoffs_staging_2
order by 1;

# Updating the table with the data
update layoffs_staging_2
set country = trim(trailing '.' from country)
where country like 'United States%';

# Convert the date column from text to date function
# Checking
select `date`
from layoffs_staging_2;

# Convert with str_to_date
select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging_2;

# Updating it to the main table
update layoffs_staging_2
set `date` = str_to_date(`date`, '%m/%d/%Y');

# Checking
select `date`
from layoffs_staging_2;

# The data has been converted to the correct format 
# We need to convert the entire column from text to date function
alter table layoffs_staging_2
modify column `date` date;

# Looking at nulls and blanks
# Checking
select *
from layoffs_staging_2;

select *
from layoffs_staging_2
where total_laid_off is null;

select *
from layoffs_staging_2
where industry is null or industry = '';

# There are nulls and blanks in industry which we can fix
# Airbnb, Carvana, Juul
select *
from layoffs_staging_2
where company = 'Airbnb';

select *
from layoffs_staging_2
where company = 'Carvana';

select *
from layoffs_staging_2
where company = 'Juul';

select *
from layoffs_staging_2
where company like "Bally's Interactive";

# Lets fix the nulls and blanks
# Bally doesnt have another row of value through which we can get industry
# It will remain blank

# Lets fix the blanks to nulls
select *
from layoffs_staging_2
where industry like '';

# Updating the blanks to nulls
update layoffs_staging_2
set industry = null
where industry = '';

# Checking
select *
from layoffs_staging_2
where industry is null;

# Lets fix it by trying to join the already filled value from other rows to the null rows
select *
from layoffs_staging_2 t1
join layoffs_staging_2 t2
	on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

# Side by Side look of null and filled data
select t1.industry, t2.industry
from layoffs_staging_2 t1
join layoffs_staging_2 t2
	on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

# Updating the table
update layoffs_staging_2 t1
join layoffs_staging_2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

# Checking
select *
from layoffs_staging_2
where industry is null;

# Removing unwanted rows and columns
# We also have rows where both total_laid_off and percentage_laid_off is null
select *
from layoffs_staging_2
where total_laid_off is null and percentage_laid_off is null;

# Delete the unwanted rows
delete 
from layoffs_staging_2
where total_laid_off is null and percentage_laid_off is null;

# We can remove of count_duplicates column as we dont use it anymore
# Checking
select *
from layoffs_staging_2;

# Altering the unwanted column
alter table layoffs_staging_2
drop column count_duplicates;

# Final Data
select *
from layoffs_staging_2;
