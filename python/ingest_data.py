import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()
# Get the password from the hidden file
db_password = os.getenv('DB_PASSWORD')
# Check if password loaded correctly 
if not db_password:
    raise ValueError("DB_PASSWORD not found in .env file. Please check your .env file.")

# Setup database connection
db_string = f"postgresql://postgres:{db_password}@localhost:5432/retail_analytics"
engine = create_engine(db_string)

print("Connected to database...")

# Load raw data
print("Loading raw data...")
df = pd.read_csv('../data/raw/online_retail.csv', encoding='ISO-8859-1')

print(f"Rows loaded: {len(df)}")

# Data Cleaning
# Drop rows with no CustomerID
df = df.dropna(subset=['CustomerID'])

# Remove cancellations (InvoiceNo starts with C)
df = df[~df['InvoiceNo'].astype(str).str.startswith('C')]

# Calculate Revenue
df['revenue'] = df['Quantity'] * df['UnitPrice']

# Parse Dates
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

print(f"Valid transactions: {len(df)}")

# Prepare Customers Table
customers = df.groupby('CustomerID').agg({
    'InvoiceDate': 'min',
    'Country': 'first'
}).reset_index()

customers.columns = ['customer_id', 'signup_date', 'region']
customers['customer_id'] = customers['customer_id'].astype(int).astype(str)

print(f"Unique customers: {len(customers)}")

# Prepare Orders Table
orders = df.groupby('InvoiceNo').agg({
    'CustomerID': 'first',
    'InvoiceDate': 'first',
    'revenue': 'sum'
}).reset_index()

orders.columns = ['order_id', 'customer_id', 'order_date', 'revenue']
orders['customer_id'] = orders['customer_id'].astype(int).astype(str)

print(f"Unique orders: {len(orders)}")

# Load to SQL
print("Loading data into PostgreSQL...")
customers.to_sql('customers', engine, if_exists='append', index=False, chunksize=1000)
orders.to_sql('orders', engine, if_exists='append', index=False, chunksize=1000)

print("Success. Data loaded.")