import psycopg2
import subprocess

conn = psycopg2.connect(database="quickvpn",
                        host="localhost",
                        user="postgres",
                        password="dZAMeoNPxhmW8jdY1BqY",
                        port="5432")

cursor = conn.cursor()

q = 'select id, ip, name from client'
cursor.execute(q)
client_records = cursor.fetchall()

for client in client_records:
    subprocess.Popen(f"umask 077; wg genkey | tee /etc/wireguard/client-config/{client[2]}.privatekey | wg pubkey > /etc/wireguard/client-config/{client[2]}.publickey", shell=True)
    subprocess.Popen(f"umask 077; wg genpsk > /etc/wireguard/client-config/{client[2]}.presharedkey", shell=True)
    subprocess.Popen(f"/home/ec2-user/quick-vpn-main/scripts/generate_client_conf.sh {client[1]} {client[2]}", shell=True)

    q = f"UPDATE client SET status = 'created' WHERE id = {client[0]}"
    cursor.execute(q)

conn.commit()

conn.close()

# restart wireguard service 

