import sys
import time
# import  config as cf 
import pandas as pd 
import pyodbc

sys.path.append(r'C:\Users\Admin\OneDrive - VNU-HCMUS\_AI23\Sharepoint\DataCo_DWH\dataset')

# read dataframe
orders = pd.read_csv(r"C:\Users\Admin\OneDrive - VNU-HCMUS\_AI23\Sharepoint\DataCo_DWH\dataset\DataCoSupplyChainDataset.csv" , encoding='latin-1')

#change invalid datatype
orders['Product Description'] = orders['Product Description'].astype("string")
orders['Order Id'] = orders['Order Id'].astype("string")
orders['Order Customer Id'] = orders['Order Customer Id'].astype("string")
orders['Department Id'] = orders['Department Id'].astype("string")
orders['Customer Id'] = orders['Customer Id'].astype("string")
orders['Category Id'] = orders['Category Id'].astype("string")

#deal with missing value 
orders = orders.fillna({'Order Zipcode': '', 'Product Description': '' , 'Customer Zipcode' : '' , 'Customer Lname' : ''}) 
# # Check if there are any NaN values in the DataFrame
# has_nan = orders.isna().any().any()
# print(f"Are there any NaN values in 'orders'? {has_nan}")
# # Count NaN values in each column
# nan_counts = orders.isna().sum()
# print("NaN values in each column:")
# print(nan_counts)

# Set up the connection to SQL Server
server = 'localhost,1434'  # Specify the port here
database = 'DB_staging'  # Your database name
username = 'sa'  # Your username
password = 'Laitoanthang219!'  # Your password


# Create a connection string
connection_string = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

# Connect to SQL Server
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()


#loop through each row 

q = """
EXEC sp_insert_datacoorders
    @type_of_transaction = ?,
    @days_for_shipping_real = ?,
    @days_for_shipment_scheduled = ?,
    @benefit_per_order = ?,
    @sales_per_customer = ?,
    @delivery_status = ?,
    @late_delivery_risk = ?,
    @category_id = ?,
    @category_name = ?,
    @customer_city = ?,
    @customer_country = ?,
    @customer_email = ?,
    @customer_fname = ?,
    @customer_id = ?,
    @customer_lname = ?,
    @customer_password = ?,
    @customer_segment = ?,
    @customer_state = ?,
    @customer_street = ?,
    @customer_zipcode = ?,
    @department_id = ?,
    @department_name = ?,
    @latitude = ?,
    @longitude = ?,
    @market = ?,
    @order_city = ?,
    @order_country = ?,
    @order_customer_id = ?,
    @order_date_dateorders = ?,
    @order_id = ?,
    @order_item_cardprod_id = ?,
    @order_item_discount = ?,
    @order_item_discount_rate = ?,
    @order_item_id = ?,
    @order_item_product_price = ?,
    @order_item_profit_ratio = ?,
    @order_item_quantity = ?,
    @sales = ?,
    @order_item_total = ?,
    @order_profit_per_order = ?,
    @order_region = ?,
    @order_state = ?,
    @order_status = ?,
    @order_zipcode = ?,
    @product_card_id = ?,
    @product_category_id = ?,
    @product_description = ?,
    @product_image = ?,
    @product_name = ?,
    @product_price = ?,
    @product_status = ?,
    @shipping_date = ?,
    @shipping_mode = ?
"""

# Convert DataFrame to list of tuples
data = [tuple(row) for row in orders.values]

# Define batch size
batch_size = 1000
start_time = time.time()
total_inserted = 0

try:
    # for i in range(0, 1000, batch_size):
    for i in range(0, len(data), batch_size):
        batch = data[i:i+batch_size]
        cursor.executemany(q, batch)
        conn.commit()
except Exception as e:
    print("Insert failed: ", e)
    conn.rollback()
    # Debugging
    for idx, row in enumerate(data):
        try:
            cursor.execute(q, row)
        except Exception as sub_e:
            print(f"Row {idx} failed: {sub_e}")
            print("Failed row: ", row)
            
end_time = time.time()

total_time = end_time - start_time


print(f"Total time taken: {total_time:.2f} seconds")

cursor.close()
conn.close()