# pip install pandas openpyxl sqlalchemy pymysql

import pandas as pd
from sqlalchemy import create_engine
import re

# Database configuration
db_username = 'root'  
db_password = 'Kapodistriako01!'  
db_host = 'localhost'         
db_port = '3306'               
db_name = 'sustainability_dashboard'      

# Create database connection
engine = create_engine(f"mysql+pymysql://{db_username}:{db_password}@{db_host}:{db_port}/{db_name}")

# Path to your Excel file
excel_file_path = 'sustainability_dashboard\data\EDGAR_2024_GHG_booklet_2024.xlsx'  

# Define sheets to exclude (optional)
excluded_sheets = ['info', 'citations and references']

# Function to clean column names
def clean_column_names(columns):
    cleaned_columns = []
    for col in columns:
        # Handle the columns represented as years
        col = str(col)
        cleaned_col = re.sub(r'[^a-zA-Z0-9_]', '', col.replace(' ', '_').lower())
        # print(col)
        # if col.isdigit():  # Check if the column name is a numeric year
        #    # print(col)
        #    cleaned_col = f"year_{col}" 
        #    # print(cleaned_col)
        # else:
        #     # print('already ok')
        #     # Replace spaces with underscores, remove special characters, and convert to lowercase
        #     cleaned_col = re.sub(r'[^a-zA-Z0-9_]', '', col.replace(' ', '_').lower())
        cleaned_columns.append(cleaned_col)
    return cleaned_columns

# Load Excel file and get all sheet names
excel_data = pd.ExcelFile(excel_file_path)
sheets = excel_data.sheet_names

# Loop through each sheet and import to MySQL
# sheets = ['GHG_totals_by_country', 'GHG_by_sector_and_country']
for sheet in sheets:
    if sheet in excluded_sheets:
        print(f"Skipping sheet: {sheet}")
        continue  # Skip the excluded sheets
    
    # Read the sheet into a DataFrame
    df = pd.read_excel(excel_file_path, sheet_name=sheet)
    
    # Clean column names
    df.columns = clean_column_names(df.columns)
    # print(df.columns)
    
    # Clean up the table name
    table_name = sheet.lower().replace(" ", "_")
    
    # Write to MySQL table
    df.to_sql(table_name, con=engine, if_exists='replace', index=False)
    print(f"Imported sheet '{sheet}' into table '{table_name}'.")
