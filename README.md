# quick vpn
wireguard vpn deployed to aws

## build
1. create key pair 
2. create security group 
3. create and iam role
4. launch ec2 instance using key pair, security group and iam role
5. connect and sudo -i
6. aws s3 cp installer and unzip - launch instance from ami and remove
7. run setup

## destroy
1. delete ec2 instance 
2. delete s3 bucket
3. delete iam role
4. delete security group 
5. delete key pair

## developing
zip -r vpn.zip quick-vpn 
aws s3 cp vpn.zip s3://quick-vpn/quick-vpn.zip