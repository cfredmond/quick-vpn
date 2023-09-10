import psycopg2

conn = psycopg2.connect(database="quick-vpn",
                        host="localhost",
                        user="postgres",
                        password="dZAMeoNPxhmW8jdY1BqY",
                        port="5432")

cursor = conn.cursor()

client_config_path = '/etc/wireguard/client-config/'
client_dns_ip = '1.1.1.1'
status = 'not-created'

address_range = range(3,255)

for address in address_range:
    client_ip = f"10.106.28.{address}/32"
    client_name = f"client{address}"
    client_pri = f"{client_config_path}{client_name}.privatekey"
    client_pub = f"{client_config_path}{client_name}.publickey"
    client_psk = f"{client_config_path}{client_name}.presharedkey"
    client_conf = f"{client_config_path}{client_name}.conf"
    
    cursor.execute('''
                   INSERT INTO client (created, updated, client_ip, client_name, client_pri, client_pub, client_psk, client_conf, client_dns_ip, status) VALUES (now(), now(), %s, %s, %s, %s, %s, %s, %s, %s);
                   ''', (client_ip, client_name, client_pri, client_pub, client_psk, client_conf, client_dns_ip, status))

conn.commit()

conn.close()