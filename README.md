# quick vpn

Acceptance criteria - user can visit url and download conf. conf selected marked as 'in-use'. if no available conf's user displayed error message.

## requirements
- aws
- wireguard client

## setup
1. launch ec2 instance
2. connect to ec2 instance. download and run installer
```bash
wget https://quick-vpn.s3.amazonaws.com/quick-vpn-main.zip && \
unzip quick-vpn-main.zip && \
cp quick-vpn-main/* . && \
chmod +x setup.sh && \
sudo ./setup.sh
```
