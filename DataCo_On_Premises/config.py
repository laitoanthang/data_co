
import pyodbc 



def create_connection(server, database, username='', password=''):
    driver = 'SQL SERVER'
    
    conn_string = (
        f'DRIVER={driver};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'UID={username};'
        f'PWD={password};'
        f'Trusted_Connection=yes;'
    )
    
    try:

        conn = pyodbc.connect(conn_string)
        cursor = conn.cursor()
        return conn, cursor
    except pyodbc.Error as e:
      
        print(f"Error connecting to the database: {e}")
        return None, None


