#!/bin/bash

dest="/etc/wireguard" # WG server main config dir
vpnif="wg0" # Wireguard interface name
_vpn_server_ip='10.106.28.1/32' # WG server's private IP
_vpn_server_udp_port='51194' # WG server UDP port
_vpn_server_ec2_ip4=$(curl -s http://checkip.amazonaws.com) # Set EC2 server's public IPv4 here for clients
publkey="${dest}/$HOSTNAME.${vpnif}.publickey" # WG server pub key
privatekey="${dest}/$HOSTNAME.${vpnif}.privatekey" # WG server private key
pskkey="${dest}/$HOSTNAME.${vpnif}.presharedkey" # WG server shared key
wgconf="/etc/wireguard/${vpnif}.conf" # WG server config file
now=$(date +"%m-%d-%Y_%H_%M_%S") # get date and time stamp 
_client_ip=$1 # vpn client IP
_client_name=$2 # vpn client name
_client_pri="${dest}/client-config/${_client_name}.privatekey" # client private key
_client_pub="${dest}/client-config/${_client_name}.publickey" # client public key
_client_psk="${dest}/client-config/${_client_name}.presharedkey" # client pre shared key
_client_conf="${dest}/client-config/${_client_name}.conf" # client config
_client_dns_ip="1.1.1.1" # I am setting cloudflare but you can set whatever you want
_bak_conf="${dest}/client-config/${vpnif}.conf.$now" # backup main wired $wgconf file

umask 077; wg genkey | tee "$_client_pri" | wg pubkey > "$_client_pub"
umask 077; wg genpsk > "$_client_psk"

cat <<EOF_CLIENT  >"$_client_conf"
# Config for $_client_name client #
[Interface]
PrivateKey = $(cat ${_client_pri})
Address = ${_client_ip}
DNS = ${_client_dns_ip}
 
[Peer]
# ${HOSTNAME}'s ${publkey} 
PublicKey = $(cat ${publkey}) 
AllowedIPs = 0.0.0.0/0
# EC2 public IP4 and port 
Endpoint = ${_vpn_server_ec2_ip4}:${_vpn_server_udp_port}
PersistentKeepalive = 15
PresharedKey = $(cat ${_client_psk})
EOF_CLIENT

cat <<EOF_WG_CONG >>"${wgconf}"
 
[Peer]
## ${_client_name} VPN config with public key taken from $dest/client-config/ dir ##
## Must match ${_client_conf} file ##
PublicKey = $(cat ${_client_pub})
AllowedIPs = ${_client_ip}
PresharedKey = $(cat ${_client_psk})
EOF_WG_CONG

systemctl restart wg-quick@wg0.service

# upload to s3
# make bucket
# aws s3 cp $_client_conf "s3://$HOSTNAME/wireguard/client-config/" &> /dev/null

