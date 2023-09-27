# quick vpn
wireguard vpn deployed to aws

## build 
1. launch ec2 instance
2. connect and sudo -i
3. aws s3 cp installer and unzip and cd
4. run setup

## destroy
1. delete ec2 instance 
2. delete iam role
3. delete security group 
4. delete s3 bucket

## developing
1. make changes
2. run zip.sh
3. upload zip file to s3