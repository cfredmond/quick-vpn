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
now=$(date +"%m-%d-%Y_%H_%M_%S") # get date and time stamp 
_bak_conf="${dest}/client-config/${vpnif}.conf.$now" # backup main wired $wgconf file

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

mv "/root/vpnif.firewall-up.sh" "$dest/scripts/${vpnif}.firewall-up.sh"
mv "/root/vpnif.firewall-down.sh" "$dest/scripts/${vpnif}.firewall-down.sh"

mv "/root/10-wireguard.conf" /etc/sysctl.d

sysctl -p /etc/sysctl.d/10-wireguard.conf

chmod -v +x /etc/wireguard/scripts/*.sh

mkdir -v "${dest}/client-config"
cp -v "$wgconf" "$_bak_conf"

aws s3 mb s3://${HOSTNAME}

# Basic while loop
counter=2
while [ $counter -le 6 ]
do
    # generate keys and conf. upload conf to s3
    _client_ip="10.106.28.${counter}/32"
    _client_name="client${counter}"
    _client_pri="${dest}/client-config/${_client_name}.privatekey" # client private key
    _client_pub="${dest}/client-config/${_client_name}.publickey" # client public key
    _client_psk="${dest}/client-config/${_client_name}.presharedkey" # client pre shared key
    _client_conf="${dest}/client-config/${_client_name}.conf" # client config
    _client_dns_ip="1.1.1.1" # I am setting cloudflare but you can set whatever you want

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

    # upload to s3
    aws s3 cp $_client_conf "s3://${HOSTNAME}/" # quick-vpn/hostname/confs/conf + used/ 
    # aws s3 presign "s3://quick-vpn/${HOSTNAME}/${_client_name}.conf"

    echo $counter
    ((counter++))
done
echo All done

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
# systemctl restart wg-quick@wg0.service

# name=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
# public_ipv4_dns=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
# hostname=`curl -s http://169.254.169.254/latest/meta-data/hostname`
# data='{"name":"'"${name}"'","public_ipv4_dns":"'"${public_ipv4_dns}"'","hostname":"'"${hostname}"'"}'

# curl --header "Content-Type: application/json" --request POST --data "$data" http://ec2-3-230-173-63.compute-1.amazonaws.com:5000/register-instance