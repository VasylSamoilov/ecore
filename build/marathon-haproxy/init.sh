#!/bin/bash

./haproxy-marathon-bridge $MARATHON_IP >/haproxy.cfg && /usr/sbin/haproxy -bd -f /haproxy.cfg 
while sleep 2
do  
	./haproxy-marathon-bridge $MARATHON_IP >/haproxy.cfg
	/usr/sbin/haproxy -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
done
