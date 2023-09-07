# quick vpn

## requirements
- aws
- wireguard client

## setup
1. launch ec2 instance
```json
{
  "MaxCount": 1,
  "MinCount": 1,
  "ImageId": "ami-0f409bae3775dc8e5",
  "InstanceType": "t3.nano",
  "KeyName": "vpn",
  "EbsOptimized": true,
  "NetworkInterfaces": [
    {
      "AssociatePublicIpAddress": true,
      "DeviceIndex": 0,
      "Groups": [
        "sg-080295a824c71c674"
      ]
    }
  ],
  "TagSpecifications": [
    {
      "ResourceType": "instance",
      "Tags": [
        {
          "Key": "Name",
          "Value": "vpn"
        }
      ]
    }
  ],
  "IamInstanceProfile": {
    "Arn": "arn:aws:iam::525067006432:instance-profile/vpn"
  },
  "PrivateDnsNameOptions": {
    "HostnameType": "ip-name",
    "EnableResourceNameDnsARecord": true,
    "EnableResourceNameDnsAAAARecord": false
  }
}
```
2. connect to ec2 instance. download and run installer
```bash
wget https://github.com/cfredmond/quick-vpn/archive/refs/tags/v0.0.1.zip && \
unzip v0.0.1.zip && \
cp quick-vpn-0.0.1/* . && \
chmod +x setup.sh && \
sudo ./setup.sh
```
