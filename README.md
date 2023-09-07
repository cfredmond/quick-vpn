# quick vpn

## requirements
- aws
- wireguard client

## setup
1. launch ec2 instance
2. connect to ec2 instance. download and run installer
```bash
wget https://github.com/cfredmond/quick-vpn/archive/refs/tags/v0.0.1.zip && \
unzip v0.0.1.zip && \
cp quick-vpn-0.0.1/* . && \
chmod +x setup.sh && \
sudo ./setup.sh
```
