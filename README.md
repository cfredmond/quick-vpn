# quick vpn

## requirements
- aws
- wireguard client

## setup
1. launch ec2 instance
   - keypair
   - security group
   - instance profile
2. connect to ec2 instance. download and run installer
   - ssh 
   - wget https://github.com/cfredmond/quick-vpn/archive/refs/tags/poc.zip
   - unzip poc.zip
   - cp quick-vpn-poc/* .
   - chmod +x setup.sh
   - sudo ./setup.sh
   - download conf
3. import and activate tunnel