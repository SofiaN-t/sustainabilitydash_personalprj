USE sustainability_dashboard;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'unpivot_ghg_totals_by_country';

-- Issue in PowerBI loading, let's check
-- SELECT * FROM unpivot_ghg_totals_by_country
-- WHERE year IS NOT NULL AND year NOT REGEXP '^[0-9]+$';
-- SELECT * FROM unpivot_ghg_totals_by_country
-- WHERE year IS NULL OR year = '';
-- SELECT year, LENGTH(year)
-- FROM unpivot_ghg_totals_by_country
-- WHERE LENGTH(year) != 4;

-- SELECT country, HEX(country)
-- FROM unpivot_ghg_totals_by_country
-- WHERE country REGEXP '[^ -~]';
-- There are some special characters that potentially throw an error with the powerbi conversion
-- Let's check
SELECT 
  DISTINCT country AS original_country,
  CONVERT(country USING ASCII) AS converted_country
FROM unpivot_ghg_totals_by_country
WHERE country REGEXP '[^ -~]';


-- Total emissions by country
SELECT country, sum(total_ghg_emissions) AS total_emissions
FROM unpivot_ghg_totals_by_country
WHERE year>=2020
GROUP BY country;

-- Top 5 countries lately
SELECT country, year, SUM(total_ghg_emissions) AS total_emissions
FROM unpivot_ghg_totals_by_country
WHERE year>=2022
GROUP BY country, year
ORDER BY total_emissions DESC LIMIT 12;
-- China, USA, India,EU27, Russia, Brazil

-- Identify rank of specific country
-- SELECT VERSION();
WITH ranked_emissions AS (
    SELECT 
        country, 
        SUM(total_ghg_emissions) AS total_emissions,
        RANK() OVER (ORDER BY SUM(total_ghg_emissions) DESC) AS ranking
    FROM 
        unpivot_ghg_totals_by_country
    WHERE 
        year>=2020
    GROUP BY 
        country
)
SELECT * FROM ranked_emissions
WHERE country =  'Greece'


-- Which industry the heavier emitter in total
-- SELECT * FROM unpivot_ghg_by_sector_and_country LIMIT 5;

SELECT substance, sector, SUM(emissions) AS emissions
FROM unpivot_ghg_by_sector_and_country
WHERE year=2023
GROUP BY substance, sector
ORDER BY emissions DESC;

-- Substance-wise emissions:
SELECT substance, country, SUM(emissions) AS emissions
FROM unpivot_ghg_by_sector_and_country
WHERE year=2023 AND country NOT IN ('EU27')
GROUP BY substance, country
ORDER BY emissions DESC;
-- China, USA, India, EU27, Russia, Japan and Iran are incl on the top

-- Total emissions to check against the ghg_totals table
SELECT country, SUM(emissions) AS total_emissions
FROM unpivot_ghg_by_sector_and_country
WHERE year=2023
GROUP BY country
ORDER BY total_emissions DESC LIMIT 10;
