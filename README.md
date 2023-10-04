# Quick VPN
Quickly setup a [Wireguard](https://www.wireguard.com) VPN on [AWS](https://aws.amazon.com/).

## Requirements
1. AWS

## Setup
1. Launch an EC2 instance.
   ![Alt text](/img/1.png?raw=true)
   ![Alt text](/img/2.png?raw=true)
   ![Alt text](/img/3.png?raw=true)
   ![Alt text](/img/key-pair.png?raw=true)
   ![Alt text](/img/4.png?raw=true)
   ![Alt text](/img/5.png?raw=true)
   ![Alt text](/img/7.png)
2. Connect to the launched instance using EC2 Instance Connect and run the following commands. 
   ![Alt text](/img/ec2_instance_connect.png)
   ```bash
   sudo -i
   aws s3 cp s3://quick-vpn/quick-vpn.zip .
   unzip quick-vpn.zip
   ./setup.sh
   rm quick-vpn.zip setup.sh
   ```
   The zip file copied from S3 includes a script that installs Wireguard as well as creates a bucket and uploads the generated key files to S3 for easy access.


## Usage
1. Download a key from from the S3 bucket created during setup. The bucket name is the EC2 instances hostname.
2. Import the key into your Wireguard client and activate the tunnel.
3. Verify that the tunnel is active in the client as well as by loading a web page.

## recovery
[TODO]

## delete
1. delete ec2 instance 
2. delete security group
3. delete iam role
4. delete s3 bucket

## developing
1. make changes
2. rm quick-vpn.zip
3. zip quick-vpn.zip setup.sh 10-wireguard.conf vpnif.firewall-*
4. aws s3 cp quick-vpn.zip s3://quick-vpn

## Architecture 
* EC2
* S3