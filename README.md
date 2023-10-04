# Quick VPN
Quickly setup a [Wireguard](https://www.wireguard.com) VPN on [AWS](https://aws.amazon.com/).

## Requirements
1. AWS

## Setup and Usage
1. Launch a EC2 instance.
2. Connect to the instance and run the following commands.
   ```bash
   sudo -i
   aws s3 cp s3://quick-vpn/setup.zip .
   unzip setup.zip
   ./setup.sh
   rm setup.zip setup.sh
   ```
3. Download a key from from the S3 bucket created during setup. The name is the instances hostname.
1. Import the key into your Wireguard client and activate the tunnel.


## Developing
1. Update the setup.sh installer script.
2. Create a zip file and upload it to S3.
   ```bash
   rm setup.zip
   zip setup.zip setup.sh 10-wireguard.conf vpnif.firewall-*
   aws s3 cp setup.zip s3://quick-vpn
   ```