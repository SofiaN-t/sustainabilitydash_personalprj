DELIMITER //

CREATE PROCEDURE UnpivotMultipleTables()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tbl_name VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'your_database_name'  -- Replace with your database name
          AND TABLE_NAME LIKE 'ghg_%';             -- Replace with a pattern to match your tables
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tbl_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Generate the unpivot query for the current table
        SET @sql = (
            SELECT GROUP_CONCAT(
                CONCAT(
                    "SELECT edgar_country_code, country, '",
                    COLUMN_NAME, 
                    "' AS year, `", 
                    COLUMN_NAME, 
                    "` AS total_ghg_emissions FROM ", tbl_name, " WHERE LENGTH(edgar_country_code) <= 10"
                ) SEPARATOR ' UNION ALL '
            )
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = tbl_name
              AND TABLE_SCHEMA = 'your_database_name'
              AND COLUMN_NAME NOT IN ('edgar_country_code', 'country')
        );

        -- Insert into a new unpivoted table (you can adjust the target table name dynamically)
        SET @sql = CONCAT(
            "INSERT INTO unpivoted_", tbl_name, " (edgar_country_code, country, year, total_ghg_emissions) ", @sql
        );

        -- Execute the dynamically generated query
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;
