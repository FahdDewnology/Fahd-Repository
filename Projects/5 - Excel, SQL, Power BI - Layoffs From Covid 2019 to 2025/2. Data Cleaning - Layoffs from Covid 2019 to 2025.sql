# Created a schema called world_layoffs and imported the dataset layoffs.csv
select * 
from world_layoffs.layoffs;

# Creating and updating a staging
create table layoffs_staging 
like layoffs;

insert layoffs_staging 
select * from layoffs;

select * 
from layoffs_staging;

# Updating the blank rows with nulls or correct values
# company
select * from layoffs_staging
where company = '';

# location
select * from layoffs_staging
where location = '';

update layoffs_staging
set location = 'San Francisco'
where location = '';

select * from layoffs_staging
where company = 'Product Hunt';

# industry
select * from layoffs_staging
where industry = '';

update layoffs_staging
set industry = 'Procuct'
where industry = '';

select * from layoffs_staging
where company = 'Appsmith';

# total_laid_off
select * from layoffs_staging
where total_laid_off = '';

update layoffs_staging
set total_laid_off = null
where total_laid_off = '';

# percentage_laid_off
select * from layoffs_staging
where percentage_laid_off = '';

update layoffs_staging
set percentage_laid_off = null
where percentage_laid_off = '';

# date
select * from layoffs_staging
where `date` = '';

# stage
select * from layoffs_staging
where stage = '';

update layoffs_staging
set stage = null
where stage = '';

# country
select * from layoffs_staging
where country = '';

# funds_raised
select * from layoffs_staging
where funds_raised = '';

update layoffs_staging
set funds_raised = null
where funds_raised = '';

# Checking for errors in unique value in the column and row data, trimming
# company
select distinct company
from layoffs_staging
order by 1;

update layoffs_staging
set company = trim(company);

# location
select distinct location
from layoffs_staging
order by 1;

update layoffs_staging
set location = trim(location);

# industry
select distinct industry
from layoffs_staging
order by 1;

update layoffs_staging
set industry = trim(industry);

# total_laid_off
select distinct total_laid_off
from layoffs_staging
order by 1;

update layoffs_staging
set total_laid_off = trim(total_laid_off);

# percentage_laid_off
select distinct percentage_laid_off
from layoffs_staging
order by 1;

update layoffs_staging
set percentage_laid_off = trim(percentage_laid_off);

# date
select distinct date
from layoffs_staging
order by 1;

update layoffs_staging
set date = trim(date);

# stage
select distinct stage
from layoffs_staging
order by 1;

update layoffs_staging
set stage = trim(stage);

# country
select distinct country
from layoffs_staging
order by 1;

update layoffs_staging
set country = trim(country);

# funds_raised
select distinct funds_raised
from layoffs_staging
order by 1;

update layoffs_staging
set funds_raised = trim(funds_raised);

# deleting rows where total_laid_off and percentage_laid_off are both null
select *
from layoffs_staging
where total_laid_off is null and percentage_laid_off is null;

delete
from layoffs_staging
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs_staging;

# Checking for repeating rows
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as count_duplicates
from layoffs_staging;

with duplicate_counter_cte as 
(
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as count_duplicates
from layoffs_staging
)

select *
from duplicate_counter_cte
where count_duplicates > 1;

# Checking the duplicate values
select *
from layoffs_staging
where company = 'Beyond Meat';

select *
from layoffs_staging
where company = 'Cazoo';

# creating another table to remove the duplicate rows of data
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int,
  `percentage_laid_off` double,
  `date` date,
  `stage` text,
  `country` text,
  `funds_raised` int,
  `count_duplicates` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# checking the new table
select *
from layoffs_staging_2;

# inserting the data along with the count_duplicates
insert into layoffs_staging_2
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as count_duplicates
from layoffs_staging;

# checking count_duplicates
select *
from layoffs_staging_2
where count_duplicates > 1;

# deleting duplicate values
delete
from layoffs_staging_2
where count_duplicates > 1;

# Checking if the duplicate values has been deleted
select *
from layoffs_staging_2
where company = 'Beyond Meat';

select *
from layoffs_staging_2
where company = 'Cazoo';

# Altering the unwanted column
alter table layoffs_staging_2
drop column count_duplicates;

# Altering column name
ALTER TABLE layoffs_staging_2 
CHANGE COLUMN funds_raised funds_raised_in_millions int;  

# Final Data
select *
from layoffs_staging_2;
