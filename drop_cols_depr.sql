-- Eventually, it was decided to drop this approach.
-- Unpivoting first is desirable since it's more flexible
-- You will not have to change your query if the table changes and
-- SQL queries with filters on rows are easier to understand and maintain




-- CREATE DATABASE IF NOT EXISTS sustainability_dashboard;
SHOW DATABASES;

USE sustainability_dashboard;

-- First scan
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_totals_by_country';

SELECT * FROM ghg_totals_by_country LIMIT 10;

-- Drop the columns that have values for the distant past
-- 1st alternative: with sql

-- Output all the columns that you can then use with an ALTER TABLE statement
-- SELECT COLUMN_NAME
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'ghg_totals_by_country'
--   AND COLUMN_NAME LIKE 'year_1%';

-- Or, you can generate all the ALTER TABLE statements to then copy and paste
SELECT CONCAT('ALTER TABLE ghg_totals_by_country DROP COLUMN ', COLUMN_NAME, ';')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_totals_by_country'
  AND COLUMN_NAME LIKE 'year_1%';

-- Generally, standard sql wouldn't allow to drop multiple cols with a single alter table statement
--However,
-- Allowed in mysql
SELECT CONCAT('ALTER TABLE ghg_totals_by_country ',
              GROUP_CONCAT('DROP COLUMN ', COLUMN_NAME SEPARATOR ', '), ';')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ghg_totals_by_country'
  AND COLUMN_NAME LIKE 'year_1%';

-- This, will create the text of the single query to then copy and paste it
-- ALTER TABLE ghg_totals_by_country DROP COLUMN year_1970, DROP COLUMN year_1971, DROP COLUMN year_1972, DROP COLUMN year_1973, DROP COLUMN year_1974, DROP COLUMN year_1975, DROP COLUMN year_1976, DROP COLUMN year_1977, DROP COLUMN year_1978, DROP COLUMN year_1979, DROP COLUMN year_1980, DROP COLUMN year_1981, DROP COLUMN year_1982, DROP COLUMN year_1983, DROP COLUMN year_1984, DROP COLUMN year_1985, DROP COLUMN year_1986, DROP COLUMN year_1987, DROP COLUMN year_1988, DROP COLUMN year_1989, DROP COLUMN year_1990, DROP COLUMN year_1991, DROP COLUMN year_1992, DROP COLUMN year_1993, DROP COLUMN year_1994, DROP COLUMN year_1995, DROP COLUMN year_1996, DROP COLUMN year_1997, DROP COLUMN year_1998, DROP COLUMN year_1999;

-- 2nd alternative: with python and sqlalchemy
