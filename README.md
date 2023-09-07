# quick vpn

## requirements
- aws
- wireguard client

## setup
1. launch ec2 instance
2. connect to ec2 instance. download and run installer
```bash
wget https://quick-vpn.s3.us-east-1.amazonaws.com/quick-vpn-main.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXUQDOWHQCVC7HHEJ%2F20230907%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230907T164724Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=421f5cac576584e3e55e92a846f30f3d724d35c7c4d41ea42aacbc687b040e0a && \
unzip quick-vpn-main.zip && \
cp quick-vpn-main/* . && \
chmod +x setup.sh && \
sudo ./setup.sh
```
