#!/bin/sh
#Configune IP-set

echo "Install ipset..."
apt install ipset -qq -y > /dev/null
echo "Done."
echo "Get ip list..."
ipset -N cnip hash:net
for i in $(curl -L https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt)
do
 ipset -A cnip $i
done
echo "Done."
echo "Write rules..."
iptables -I INPUT -p tcp --dport 443 -j DROP
iptables -I INPUT -p tcp --dport 80 -j DROP
iptables -I INPUT -p tcp -m set --match-set cnip src -j ACCEPT
echo "Done."
echo "Successful setting the ip-block!"
exit 0