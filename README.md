# quick vpn
wireguard vpn deployed to aws

## build
1. create key pair 
2. create security group 
3. create and iam role
4. launch ec2 instance using key pair, security group and iam role
5. connect and sudo -i
6. aws s3 cp installer - launch instance from ami and remove 
7. chmod +x setup and generate client conf - launch instance from ami and remove 
8. run setup
9. run generate client conf passing ip and name
10. use presigned url download conf

## destroy
1. delete ec2 instance 
2. delete s3 bucket
3. delete iam role
4. delete security group 
5. delete key pair