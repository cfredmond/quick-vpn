# pip install psycopg2-binary

import psycopg2

conn = psycopg2.connect(database="quickvpn",
                        host="localhost",
                        user="postgres",
                        password="dZAMeoNPxhmW8jdY1BqY",
                        port="5432")

cursor = conn.cursor()

status = 'not-created'

address_range = range(3,255)

for address in address_range:
    ip = f"10.106.28.{address}/32"
    name = f"client{address}"
    
    cursor.execute('''
                   INSERT INTO client (created, updated, ip, name, status) VALUES (now(), now(), %s, %s, %s);
                   ''', (ip, name, status))

conn.commit()

conn.close()