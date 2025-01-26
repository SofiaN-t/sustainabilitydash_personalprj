import pymysql

# Database connection
connection = pymysql.connect(
    host='localhost',
    user='root',
    password='Kapodistriako01!',
    database='sustainability_dashboard'
)

## DEPRECATED ##

### SQLAlchemy to dynamically unpivot multiple tables
# import mysql.connector

# # Connect to the database
# connection = mysql.connector.connect(
#     host="localhost",
#     user="your_username",
#     password="your_password",
#     database="your_database"
# )

cursor = connection.cursor()

# Fetch all matching table names
cursor.execute("""
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'your_database'
      AND TABLE_NAME LIKE 'ghg_%'
""")
tables = cursor.fetchall()

# Loop through each table and unpivot it
for (table_name,) in tables:
    # Generate dynamic unpivot query
    cursor.execute(f"""
        SELECT GROUP_CONCAT(
            CONCAT(
                "SELECT edgar_country_code, country, '",
                COLUMN_NAME,
                "' AS year, `",
                COLUMN_NAME,
                "` AS total_ghg_emissions FROM {table_name} WHERE LENGTH(edgar_country_code) <= 10"
            ) SEPARATOR ' UNION ALL '
        ) INTO @sql
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '{table_name}'
          AND TABLE_SCHEMA = 'your_database'
          AND COLUMN_NAME NOT IN ('edgar_country_code', 'country');
    """)

    # Fetch and execute the dynamic query
    cursor.execute("SELECT @sql")
    query = cursor.fetchone()[0]
    cursor.execute(f"INSERT INTO unpivoted_{table_name} {query}")

# Commit changes
connection.commit() 
cursor.close()
connection.close()


### SQLAlchemy to drop matching cols
# For one table
try:
    with connection.cursor() as cursor:
        # Fetch matching columns
        cursor.execute("""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'ghg_totals_by_country'
              AND COLUMN_NAME LIKE 'year_1%';
        """)
        columns = cursor.fetchall()

        # Drop matching columns
        for (column_name,) in columns:
            drop_query = f"ALTER TABLE ghg_totals_by_country DROP COLUMN {column_name};"
            cursor.execute(drop_query)
        connection.commit()
finally:
    connection.close()


# Doing this for multiple tables at once

# Pattern to match columns
pattern = 'year_1%' 

try:
    with connection.cursor() as cursor:
        # Step 1: Fetch all tables and their columns matching the pattern
        cursor.execute(f"""
            SELECT TABLE_NAME, COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND COLUMN_NAME LIKE '{pattern}';
        """)
        columns_to_drop = cursor.fetchall()  # List of (table_name, column_name)

        # Step 2: Organize columns by table
        tables_columns = {}
        for table_name, column_name in columns_to_drop:
            if table_name not in tables_columns:
                tables_columns[table_name] = []
            tables_columns[table_name].append(column_name)

        # Step 3: Generate and execute ALTER TABLE statements for each table
        for table_name, columns in tables_columns.items():
            drop_columns_sql = ", ".join([f"DROP COLUMN {column}" for column in columns])
            alter_table_sql = f"ALTER TABLE {table_name} {drop_columns_sql};"
            print(f"Executing: {alter_table_sql}")  # For debugging/logging purposes
            cursor.execute(alter_table_sql)

        # Commit changes to the database
        connection.commit()
finally:
    connection.close()
