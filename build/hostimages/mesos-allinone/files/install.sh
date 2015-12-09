#!/bin/bash

#This script is doing all the long running artifacts download during backing phase.

sudo /usr/bin/mkdir -p /opt/bin
sudo /usr/bin/wget -O /opt/bin/calicoctl http://www.projectcalico.org/latest/calicoctl
sudo /usr/bin/chmod +x /opt/bin/calicoctl

docker pull nixlike/docker-zk-exhibitor &
pid1=$!

docker pull mesoscloud/mesos-master:0.24.1-ubuntu-14.04 &
pid2=$!

docker pull mesoscloud/marathon:0.11.0-ubuntu-15.04 &
pid3=$!

docker pull nixlike/mesos-slave:mesos-0.24.1_docker-1.9.1 &
pid4=$!

docker pull calico/node:latest &
pid5=$!

docker pull calico/node-libnetwork:latest &
pid6=$!

wait $pid1
wait $pid2
wait $pid3
wait $pid4
wait $pid5
wait $pid6

#Create folder for vagrant usedata
sudo mkdir -p /var/lib/coreos-vagrant

