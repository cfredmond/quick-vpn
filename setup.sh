#!/bin/bash

# set repo url and file #
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


#
now=$(date +"%m-%d-%Y_%H_%M_%S") # get date and time stamp 
_client_ip='10.106.28.2/32' # vpn client IP
_client_name='client' # vpn client name
_client_pri="${dest}/client-config/${_client_name}.privatekey" # client private key
_client_pub="${dest}/client-config/${_client_name}.publickey" # client public key
_client_psk="${dest}/client-config/${_client_name}.presharedkey" # client pre shared key
_client_conf="${dest}/client-config/${_client_name}.conf" # client config
_client_dns_ip="1.1.1.1" # I am setting cloudflare but you can set whatever you want
_bak_conf="${dest}/client-config/${vpnif}.conf.$now" # backup main wired $wgconf file

yum upgrade
amazon-linux-extras install -y epel

# Download it
wget --output-document="$rwfile" "$rwurl"
yum clean all
yum install wireguard-dkms wireguard-tools

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

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

# aws s3 mb "s3://$HOSTNAME"
# cp client file to s3
# VPN_CONF_LINK = generate a presigned url

# aws ses send-email --from charles.redmond+ses@gmail.com --to charles.redmond+ses@gmail.com --text "$VPN_CONF_LINK" --subject "vpn conf"

# aws ses send-email --from charles.redmond+ses@gmail.com --to charles.redmond+ses@gmail.com --text "https://s3.amazonaws.com/ip-172-31-78-201.ec2.internal/client.conf?AWSAccessKeyId=ASIAXUQDOWHQAKPN3F6P&Expires=1694005770&x-amz-security-token=IQoJb3JpZ2luX2VjEJ3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQDUFMKYNBaPgX034fYahHgaxwv7%2BwFTrWrJ5u6PyNvUTgIgSAO5ixPct6KNXnnq5fa1557WDw2S3LXqCoopAMg7d1IqtAUIdRACGgw1MjUwNjcwMDY0MzIiDImF0GUKRTq1SAk7eyqRBeYTwPs7Ux1vseu9DmaHN7Z1Dmk4qGLSTM3KtaEVtYPQF9DIeNk5DbADY4aAxEPzxiIYxEEZ5jPcqtg1v5R7vPQBSKhQEXNieKEaccZdSeubM7MLN9VtKwS0knIagenXJZk4AqwWNXAo4S4p5g9z6xmkjwXaXuKF3kNPzGGgkJJeiB%2BD2XJxxh2ifn9pagA85Dc0mGOfM7Iho8MOgLu2vJyDTWXE%2BQWiamARvHq5HLBSySE3GRTcaFONHpisRUIdu8Wic7peBq%2Bd3kN5qAwjgNP4gncjSMWQtYSpD%2B2OoZgdQW2D0nSbypvUKvTFrsBWnRBTb4FW15tO36DQBm6wkGQqzAG2kzniUAZCAO1Y%2F92SdAlBpaxdzh4IbUCqUEcngmpiTx88sQlntwCEEYdgHgFYgvrgzTS2I%2FTf%2FfgXgrqzB%2Fc46ojmGCBYVOob9%2B7YohjSnztrltLCQCmDDRUL5nA3tsj%2BnhHOU48YeJ%2FVtea3ePrawYXJyx0qc97gEuJjgE3i%2Fd21cOHz%2FmGvuUG8YjdHBGDntX3YCH1YXZHga6qvzC01rDdCY7ZbRL6Bwi4kLeBpoi8UHoLEbqfXVuJ2Zod9Kt2RZaVwizbi3J2ykxDLLjiDQjkyBE%2BsZXsMIZ3%2BDuBNic7XS9XhLwFmhVTdVSlgNg%2F5CXfd6AMSpf%2FwZv5RmoBnBb3H9IVhKLXhOuD88ndmuUhnJdmAfBryy5OugwyQRaTurohatI%2BpUCyr2VDIJStVKFhldJ98bysfl1CMHUOZcokbi6uYyU%2FMuDOBsEZotxBIlVek493rCzrn0HOqaIePrNBZVKxBTjJfzHdVdL9aU36gzxoXLlEyUGEyoRDky%2FN5UYaaQMYzrZiRTtqjHDCl1uGnBjqxAW7gWzF8J7J0QlRFfnp3Az71yCRfrIdoX%2F6%2BTzPM0eANPUujtBT8%2ByWeZGNoNnsFavSIFQH%2Ft3xs38RynQuZeCkdTpPgJMhJuWwwgvUByFmDO7vqLhzL5y6lheOxGkq4car9MpzBqiJcW1byJ%2BymsTDo1hnloIN%2BGNRrGiFrvSyJ26q9bltcD4%2BivUQa8H185wV4kJ5421L5iZGcX4qbdILqrM%2FUpA06nbLRQAqT9j5tgQ%3D%3D&Signature=fckZxa1kI2FPW4QC7C33pQ6kTsU%3D" --subject "vpn conf"