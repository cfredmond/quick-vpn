import psycopg2
import subprocess

conn = psycopg2.connect(database="quick-vpn",
                        host="localhost",
                        user="postgres",
                        password="dZAMeoNPxhmW8jdY1BqY",
                        port="5432")

cursor = conn.cursor()

q = 'select * from client limit 1'
cursor.execute(q)
client_records = cursor.fetchall()

for client in client_records:
    subprocess.Popen(f"umask 077; wg genkey | tee {client[5]} | wg pubkey > {client[6]}", shell=True)
    subprocess.Popen(f"umask 077; wg genpsk > {client[7]}", shell=True)

    subprocess.Popen(f"/home/ec2-user/generate_client_conf.sh {client[8]} {client[4]} {client[5]} {client[3]} {client[6]} {client[7]} {client[9]}", shell=True)

    s3_url = 's3://ip-172-31-67-15.ec2.internal/wireguard/client-config/' + client[8][29:]
    q = f"UPDATE client SET status = 'created', s3_url = {s3_url} WHERE id = {client[0]}"

    cursor.execute(q)

conn.commit()
conn.close()
# wireguard restart service

