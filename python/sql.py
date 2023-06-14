import psycopg2
connection = psycopg2.connect(
    database='testsql', 
    user='postgres', 
    password='so123046', 
    host='127.0.0.1', 
    port=5432)
cursor = connection.cursor()
cursor.close()
connection.close()