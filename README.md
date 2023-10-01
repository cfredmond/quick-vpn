# quick vpn
wireguard vpn deployed to aws

## build 
1. launch ec2 instance
   1. create key
   2. create security group
   3. create iam role
2. connect and sudo -i
3. aws s3 cp s3://quick-vpn/quick-vpn.zip .
4. unzip quick-vpn.zip
5. ./setup.sh

## destroy
1. delete ec2 instance 
2. delete s3 bucket
3. delete iam role
4. delete security group 
5. delete key

## developing
1. make changes
2. rm quick-vpn.zip
3. zip quick-vpn.zip setup.sh 10-wireguard.conf vpnif.firewall-*
4. aws s3 cp quick-vpn.zip s3://quick-vpn