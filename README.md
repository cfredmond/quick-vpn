# Quick VPN
Quickly setup a [Wireguard](https://www.wireguard.com) VPN on [AWS](https://aws.amazon.com/)

## Requirements
1. AWS

## Setup
1. Launch a EC2 instance
   1. Select the Amazon Linux 2 AMI and 64-bit (x86) Architecture
   ![Alt text](/img/ami.png?raw=true)
   2. create security group
   ![Alt text](/img/security_group.png?raw=true)
   3. create instance profile
   ![Alt text](/img/instance_profile.png?raw=true)
   4. review your selection and click launch instance
   ![Alt text](/img/launch_instance.png?raw=true)
2. connect to instance and run the following:
   ```bash
   sudo -i
   aws s3 cp s3://quick-vpn/quick-vpn.zip .
   unzip quick-vpn.zip
   ./setup.sh
   ```

## use
1. download conf from s3
2. mv downloaded conf to used folder in bucket
3. import tunnel in client
4. activate tunnel

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

## architecture 
[TODO]