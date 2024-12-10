#  Data Cleaning - Its where you convert the data into a more usable format. So you fix alot of the issues in the raw data
# So there is no issue when you use the data in a product or to visualize

# We are going to :
-- 1. Create a database
-- 2. Import a real data set
-- 3. Clean the data

# 1. Create a database
# To create a data base click on Create a new schema in the connected server - 4 icon the tool bar - Name: world_layoffs
# or use the below execution code
CREATE SCHEMA `world_layoffs` ;

# 2. Import a real data set
# In schema select world_layoffs, right click on tables and click Table data import wizard
# and provide the file path
# Use existing table or Create a new table and check drop table if exits if required
# configure the import settings as required - Generally keep everything the same unless required
# We can change the date in the table from text to date and time
# but for now we will keep the raw data

select *
from layoffs;

# 3. Clean the data
# There are various steps
-- 1. Remove duplicates	
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns - Sometimes this can be done and Sometimes this should not be done
	-- If you have irrelevant column then you can remove it but
    -- In work places there are processes that automatically import data and If you remove columns from the raw data set
    -- its a big problem.
    -- It is better to create a staging or seperate the raw dataset as a another data set
    -- which is nothing but the copy of original data set. Use the below code for doing that
    -- We can use the staging data set for our use and layoffs will be the original raw data which we wont change

# this creates the table but no data    
create table layoffs_staging
like layoffs;

# insert the data from layoffs
insert layoffs_staging
select *
from layoffs;

# checking
select *
from layoffs_staging;

# 3.1 - Removing duplicates

select *
from layoffs_staging;

# we will try to find rows which repeat using a function called row_number()
# row_number() returns the number of a row with a partition of a result set

select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging;

# date is a function so we will put them in ticks
# there is going to be a new column called count_duplicates which denotes the number of rows with the current values
# it can 1, 2 or more

# lets put the above code in a cte so we can create another code to check if there is any value in count_duplicates greater than 1

with duplicate_counter_cte as 
(
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging
)

select *
from duplicate_counter_cte
where count_duplicates > 1;

# running the above code will show all rows which have repeated more than once

# lets just one of the companies and see the duplicate

select *
from layoffs_staging
where company = 'Casper';

# From the 3 rows of output, the 1st and the 3rd are the same row. One of them needs to be removed

# We now need to remove these unwanted rows
# We cannot delete the rows directly from the cte as the mysql does not allow it
# So we can remove them by creating another table which has the count duplicates column then filter the value 2 and remove the necessary

# Lets create a new table naming layoffs_staging_2 by using the code of the schema
# right click on layoff_staging and go to copy to clip board and click on create statement
# Here add the extra column - count_duplicates and make it an integer

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

# the new table is created but it doesnt have any data
select *
from layoffs_staging_2;

# now lets insert the row number data into the new table

insert into layoffs_staging_2
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as count_duplicates
from layoffs_staging;

# now the table has the data for the count_duplicates
select *
from layoffs_staging_2;

# now lets check for the duplicates
select *
from layoffs_staging_2
where count_duplicates > 1
;

# now lets delete these values as these are duplicate values and the first values is already safe with count_duplicates as 1
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













    
