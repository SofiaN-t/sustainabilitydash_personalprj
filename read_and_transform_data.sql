-- CREATE DATABASE IF NOT EXISTS sustainability_dashboard;
SHOW DATABASES;

USE sustainability_dashboard;

-- First scan
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_totals_by_country';

SELECT * FROM ghg_totals_by_country LIMIT 10;

-- Check all table names
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sustainability_dashboard';
-- [ghg_totals_by_country, ghg_per_capita_by_country, ghg_by_sector_and_country,
-- ghg_per_gdp_by_country, lulucf_macroregions]

-- Unpivot for easier analysis

-- First, construct the query:
-- Get the column names and make it all a string
-- First increase the size limit allowed to the GROUP_CONCAT()
SET SESSION group_concat_max_len = 100000;

SELECT GROUP_CONCAT(
    CONCAT("SELECT edgar_country_code, country, '", 
    COLUMN_NAME, 
    "' AS year, `", 
    COLUMN_NAME, 
    "` AS total_ghg_emissions FROM ghg_totals_by_country WHERE LENGTH(edgar_country_code)<10"
    ) SEPARATOR ' UNION ALL '
) INTO @sql
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_totals_by_country'
  AND COLUMN_NAME NOT IN ('country', 'edgar_country_code');

-- Check the query
SELECT @sql;

-- Check what it generates for two rows
-- SELECT edgar_country_code, country, '1970' AS year, `1970` AS total_ghg_emissions FROM ghg_totals_by_country 
-- UNION ALL 
-- SELECT edgar_country_code, country, '1971' AS year, `1971` AS total_ghg_emissions FROM ghg_totals_by_country;
-- This works

-- To save the result as new table
-- DROP TABLE unpivot_ghg_totals_by_country;

-- First make the table with desired data types
CREATE TABLE unpivot_ghg_totals_by_country (
    edgar_country_code VARCHAR(10),
    country VARCHAR(100),
    year INT,
    total_ghg_emissions FLOAT
);

SET @sql = CONCAT(
    "INSERT INTO unpivot_ghg_totals_by_country (edgar_country_code, country, year, total_ghg_emissions) ",
    @sql
);

-- Execute the query
PREPARE stmt FROM @sql;  -- Prepare the dynamic query
-- Make sure you have increased the limit of the group_concat
EXECUTE stmt;            -- Execute the query
DEALLOCATE PREPARE stmt;

-- Manually check the PREPARE statement
-- SET @sql = "SELECT edgar_country_code, country, '1970' AS year, `1970` AS total_ghg_emissions FROM ghg_totals_by_country UNION ALL SELECT edgar_country_code, country, '1971' AS year, `1971` AS total_ghg_emissions FROM ghg_totals_by_country;
-- ";
-- This worked
-- PREPARE stmt FROM @sql;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;

-- Check how the new table looks like
SELECT * FROM unpivot_ghg_totals_by_country LIMIT 10;


-- Follow exactly the same process for other tables of interest
-- Alternatively:
-- Either 
-- Consult read_and_transform_multiple_tables.sql with an example of
-- automating the process by creating a stored procedure
-- Or
-- Do this externally via Python and SQLALchemy,consult modify_with_python.py


-- Continue with the rest of the tables
-- [ghg_totals_by_country, ghg_per_capita_by_country, 
-- ghg_by_sector_and_country,
-- ghg_per_gdp_by_country, lulucf_macroregions]

SELECT * FROM ghg_by_sector_and_country LIMIT 10;
SELECT DISTINCT substance FROM ghg_by_sector_and_country;

-- Construct the query
SELECT GROUP_CONCAT(
    CONCAT("SELECT substance, sector, edgar_country_code, country, '", 
    COLUMN_NAME, 
    "' AS year, `", 
    COLUMN_NAME, 
    "` AS emissions FROM ghg_by_sector_and_country WHERE LENGTH(edgar_country_code)<10"
    ) SEPARATOR ' UNION ALL '
) INTO @sql
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_by_sector_and_country'
  AND COLUMN_NAME NOT IN ('substance', 'sector', 'country', 'edgar_country_code');

-- Check the query
SELECT @sql;

-- To save the result as new table
CREATE TABLE unpivot_ghg_by_sector_and_country (
    substance VARCHAR(30),
    sector VARCHAR(30),
    edgar_country_code VARCHAR(10),
    country VARCHAR(100),
    year INT,
    emissions FLOAT
);

SET @sql = CONCAT(
    "INSERT INTO unpivot_ghg_by_sector_and_country (substance, sector, edgar_country_code, country, year, emissions) ",
    @sql
);

-- Execute the query
PREPARE stmt FROM @sql;
EXECUTE stmt;            
DEALLOCATE PREPARE stmt;

-- Check how the new table looks like
SELECT * FROM unpivot_ghg_by_sector_and_country LIMIT 20;

-- Next table
-- [ghg_totals_by_country, ghg_per_capita_by_country, 
-- ghg_by_sector_and_country,
-- ghg_per_gdp_by_country, lulucf_macroregions]

SELECT * FROM ghg_per_capita_by_country LIMIT 10;

-- Construct the query
SELECT GROUP_CONCAT(
    CONCAT("SELECT edgar_country_code, country, '", 
    COLUMN_NAME, 
    "' AS year, `", 
    COLUMN_NAME, 
    "` AS per_capita_emissions FROM ghg_per_capita_by_country WHERE LENGTH(edgar_country_code)<10"
    ) SEPARATOR ' UNION ALL '
) INTO @sql
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_per_capita_by_country'
  AND COLUMN_NAME NOT IN ('country', 'edgar_country_code');

-- Check the query
SELECT @sql;

-- To save the result as new table
CREATE TABLE unpivot_ghg_per_capita_by_country (
    edgar_country_code VARCHAR(10),
    country VARCHAR(100),
    year INT,
    per_capita_emissions FLOAT
);

SET @sql = CONCAT(
    "INSERT INTO unpivot_ghg_per_capita_by_country (edgar_country_code, country, year, per_capita_emissions) ",
    @sql
);

-- Execute the query
PREPARE stmt FROM @sql;
EXECUTE stmt;            
DEALLOCATE PREPARE stmt;

-- Check how the new table looks like
SELECT * FROM unpivot_ghg_per_capita_by_country LIMIT 10;


-- Next table
-- [ghg_totals_by_country, ghg_per_capita_by_country, 
-- ghg_by_sector_and_country,
-- ghg_per_gdp_by_country, lulucf_macroregions]

SELECT * FROM ghg_per_gdp_by_country LIMIT 10;

-- Construct the query
SELECT GROUP_CONCAT(
    CONCAT("SELECT edgar_country_code, country, '", 
    COLUMN_NAME, 
    "' AS year, `", 
    COLUMN_NAME, 
    "` AS per_gdp_emissions FROM ghg_per_gdp_by_country WHERE LENGTH(edgar_country_code)<10"
    ) SEPARATOR ' UNION ALL '
) INTO @sql
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_per_gdp_by_country'
  AND COLUMN_NAME NOT IN ('country', 'edgar_country_code');

-- Check the query
SELECT @sql;

-- To save the result as new table
CREATE TABLE unpivot_ghg_per_gdp_by_country (
    edgar_country_code VARCHAR(10),
    country VARCHAR(100),
    year INT,
    per_gdp_emissions FLOAT
);

SET @sql = CONCAT(
    "INSERT INTO unpivot_ghg_per_gdp_by_country (edgar_country_code, country, year, per_gdp_emissions) ",
    @sql
);

-- Execute the query
PREPARE stmt FROM @sql;
EXECUTE stmt;            
DEALLOCATE PREPARE stmt;

-- Check how the new table looks like
SELECT * FROM unpivot_ghg_per_gdp_by_country LIMIT 10;

-- Update the tables with the mapped countries to avoid incompatibilities with PowerBI
-- Make sure a column exists to hold the new values
ALTER TABLE unpivot_ghg_totals_by_country
ADD COLUMN mapped_country VARCHAR(100);

-- Join with the mapped countries 
UPDATE unpivot_ghg_totals_by_country AS o
LEFT JOIN mapping_countries AS m
ON o.country = m.original_country
SET o.mapped_country = COALESCE(m.mapped_country, o.country);

-- SELECT * FROM unpivot_ghg_totals_by_country;
-- Keep as country the mapped_country column
UPDATE unpivot_ghg_totals_by_country
SET country = mapped_country;
ALTER TABLE unpivot_ghg_totals_by_country
DROP COLUMN mapped_country;

-- Do the same for the other tables
ALTER TABLE unpivot_ghg_by_sector_and_country
ADD COLUMN mapped_country VARCHAR(100);
-- Join with the mapped countries 
UPDATE unpivot_ghg_by_sector_and_country AS o
LEFT JOIN mapping_countries AS m
ON o.country = m.original_country
SET o.mapped_country = COALESCE(m.mapped_country, o.country);
-- Keep as country the mapped_country column
UPDATE unpivot_ghg_by_sector_and_country
SET country = mapped_country;
ALTER TABLE unpivot_ghg_by_sector_and_country
DROP COLUMN mapped_country;
-- SELECT * FROM unpivot_ghg_by_sector_and_country LIMIT 20;

-- Next table
ALTER TABLE unpivot_ghg_per_capita_by_country
ADD COLUMN mapped_country VARCHAR(100);
-- Join with the mapped countries 
UPDATE unpivot_ghg_per_capita_by_country AS o
LEFT JOIN mapping_countries AS m
ON o.country = m.original_country
SET o.mapped_country = COALESCE(m.mapped_country, o.country);
-- Keep as country the mapped_country column
UPDATE unpivot_ghg_per_capita_by_country
SET country = mapped_country;
ALTER TABLE unpivot_ghg_per_capita_by_country
DROP COLUMN mapped_country;
-- SELECT * FROM unpivot_ghg_per_capita_by_country LIMIT 20;

-- Next table
ALTER TABLE unpivot_ghg_per_gdp_by_country
ADD COLUMN mapped_country VARCHAR(100);
-- Join with the mapped countries 
UPDATE unpivot_ghg_per_gdp_by_country AS o
LEFT JOIN mapping_countries AS m
ON o.country = m.original_country
SET o.mapped_country = COALESCE(m.mapped_country, o.country);
-- Keep as country the mapped_country column
UPDATE unpivot_ghg_per_gdp_by_country
SET country = mapped_country;
ALTER TABLE unpivot_ghg_per_gdp_by_country
DROP COLUMN mapped_country;
-- SELECT * FROM unpivot_ghg_per_gdp_by_country LIMIT 20;

