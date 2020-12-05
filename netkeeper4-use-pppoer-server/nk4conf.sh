#!/bin/sh

#change log location & enable debug & show password
sed -i "s/\/dev\/null/\/tmp\/pppoe.log/" /etc/ppp/options
#echo "lcp-echo-failure 1" >> /etc/ppp/options
#echo "lcp-echo-interval 10" >> /etc/ppp/options
sed -i "s/#debug/debug/" /etc/ppp/options
echo "show-password" >> /etc/ppp/options

cp /etc/ppp/plugins/rp-pppoe.so /etc/ppp/plugins/rp-pppoe.so.bak
cp /usr/lib/pppd/2.4.7/rp-pppoe.so /etc/ppp/plugins/rp-pppoe.so

uci set network.wan=interface
uci set network.wan.ifname=$(uci show network.wan.ifname | awk -F "'" '{print $2}')
uci set network.wan.proto=pppoe
uci set network.wan.username=username
uci set network.wan.password=password
uci set network.wan.metric='0'
uci set network.wan.auto='0'
uci commit network

/etc/init.d/network reload
/etc/init.d/network restart

#enable \r in PPPoE
cp /lib/netifd/proto/ppp.sh /lib/netifd/proto/ppp.sh_bak
sed -i '/proto_run_command/i username=`echo -e "$username"`' /lib/netifd/proto/ppp.sh

#set init script
cp /root/nk4 /etc/init.d/nk4
chmod +x /etc/init.d/nk4
/etc/init.d/nk4 enable
sleep 5
reboot
