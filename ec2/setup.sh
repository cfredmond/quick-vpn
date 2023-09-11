#!/bin/bash

# install wireguard
rwfile="/etc/yum.repos.d/wireguard.repo"
rwurl="https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo"
dest="/etc/wireguard" # WG server main config dir
vpnif="wg0" # Wireguard interface name
_vpn_server_ip='10.106.28.1/32' # WG server's private IP
_vpn_server_udp_port='51194' # WG server UDP port
_vpn_server_ec2_ip4=$(curl -s http://checkip.amazonaws.com) # Set EC2 server's public IPv4 here for clients
publkey="${dest}/$HOSTNAME.${vpnif}.publickey" # WG server pub key
privatekey="${dest}/$HOSTNAME.${vpnif}.privatekey" # WG server private key
pskkey="${dest}/$HOSTNAME.${vpnif}.presharedkey" # WG server shared key
wgconf="/etc/wireguard/${vpnif}.conf" # WG server config file

yum upgrade -y
amazon-linux-extras install -y epel

wget --output-document="$rwfile" "$rwurl"
yum clean all -y
yum install -y wireguard-dkms wireguard-tools

pushd /etc/wireguard/
umask 077

wg genkey | tee "${privatekey}" | wg pubkey > "${publkey}"
wg genpsk > "${pskkey}"

touch $wgconf

cat <<E_O_F_WG >"$wgconf"
## Set Up WireGuard VPN server on $HOSTNAME  ##
[Interface]
## My VPN server private IP address ##
Address = ${_vpn_server_ip}
 
## My VPN server port ##
ListenPort = ${_vpn_server_udp_port}
 
## VPN server's private key i.e. $privatekey ##
PrivateKey = $(<"${privatekey}")
 
## Set up firewall routing here
PostUp = ${dest}/scripts/${vpnif}.firewall-up.sh
PostDown = ${dest}/scripts/${vpnif}.firewall-down.sh
 
E_O_F_WG

mkdir "$dest/scripts"

mv "/home/ec2-user/vpnif.firewall-up.sh" "$dest/scripts/${vpnif}.firewall-up.sh"
mv "/home/ec2-user/vpnif.firewall-down.sh" "$dest/scripts/${vpnif}.firewall-down.sh"

mv "/home/ec2-user/10-wireguard.conf" /etc/sysctl.d

sysctl -p /etc/sysctl.d/10-wireguard.conf

chmod -v +x /etc/wireguard/scripts/*.sh

mkdir -v "${dest}/client-config"
cp -v "$wgconf" "$_bak_conf"

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service


# install docker
yum install docker
usermod -a -G docker ec2-user
yum install python3-pip
pip3 install docker-compose

systemctl enable docker.service
systemctl start docker.service