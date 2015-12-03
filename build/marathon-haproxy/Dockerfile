FROM ubuntu:14.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y haproxy wget curl
RUN wget https://raw.githubusercontent.com/mesosphere/marathon/master/bin/haproxy-marathon-bridge && chmod +x haproxy-marathon-bridge 

ADD ./init.sh /etc/init.d/init.sh

ENTRYPOINT /etc/init.d/init.sh
