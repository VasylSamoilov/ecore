#!/bin/bash

#This script is doing all the long running artifacts download during backing phase.


docker pull nixlike/docker-zk-exhibitor &
pid1=$!

docker pull mesoscloud/mesos-master:0.24.1-ubuntu-14.04 &
pid2=$!

docker pull mesoscloud/marathon:0.11.0-ubuntu-15.04 &
pid3=$!

docker pull nixlike/mesos-slave:mesos-0.24.1_docker-1.10.0 &
pid4=$!

docker pull calico/node:latest &
pid5=$!

docker pull calico/node-libnetwork:v0.7.0 &
pid6=$!

docker pull gliderlabs/registrator:v6 &
pid7=$!

docker pull nixlike/buildcont:ubuntu-15.10 &
pid8=$!

sudo /usr/bin/mkdir -p /opt/bin
sudo /usr/bin/wget -O /opt/bin/calicoctl http://www.projectcalico.org/latest/calicoctl
pid9=$!
sudo /usr/bin/chmod +x /opt/bin/calicoctl

sudo /usr/bin/wget -O /opt/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64
pid10=$!
sudo /usr/bin/chmod +x /opt/bin/confd

sudo /usr/bin/wget -O /opt/bin/mesos-dns https://github.com/mesosphere/mesos-dns/releases/download/v0.5.1/mesos-dns-v0.5.1-linux-amd64
pid11=$!
sudo /usr/bin/chmod +x /opt/bin/mesos-dns

wait $pid1
wait $pid2
wait $pid3
wait $pid4
wait $pid5
wait $pid6
wait $pid7
wait $pid8
wait $pid9
wait $pid10
wait $pid11
