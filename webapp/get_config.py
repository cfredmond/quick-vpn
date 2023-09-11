# flask --app get_config run --host=0.0.0.0

import psycopg2
import boto3
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    conn = psycopg2.connect(database="quick-vpn",
                        host="localhost",
                        user="postgres",
                        password="dZAMeoNPxhmW8jdY1BqY",
                        port="5432")

    s3_client = boto3.client('s3')

    cursor = conn.cursor()
    q = "SELECT s3_url, id FROM client WHERE status = 'created' LIMIT 1"
    cursor.execute(q)
    client_records = cursor.fetchall()

    # url = ''

    for client in client_records:
        url = s3_client.generate_presigned_url('get_object', Params={'Bucket': 'ip-172-31-67-15.ec2.internal', 'Key': client[0][34:]}, ExpiresIn=3600)

    return f"<p>{url}</p>"