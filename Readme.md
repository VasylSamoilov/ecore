# ECORE
Full featured Mesos sandbox

###Objectives

* The easiest way to learn, rollout and maintain mesos platform
* No closed artifacts, track everything from source code.
* Cross cloud / cross region cluster
* Run all workloads on single pool resources ( no static partitioning )

###Implemented Features

* Easy for modification and development, since everything, including infrastructure is immutable and managed via the same repository.
* Security applied starting from DEV
* Scallability and HA out of the box
* [Mesosphere DCOS](https://mesosphere.com) cli compatible
* Automatic OpenVPN tunnel provisioning during cluster bootstrap

###Build blocks

* [Packer](https://www.packer.io) same templates to build any server
* [Terraform](https://terraform.io) for real infrastructure as a code
* [CoreOS](https://coreos.com) as a minimalistic basement of any host
* [Docker](https://www.docker.com) for anything else
* [Mesos](http://mesos.apache.org) a distribuited cluster kernel
* [Marathon](https://mesosphere.github.io/marathon/) a distribuited cluster kernel

###To be implemented
* Live cross region cluster modification and worload migrations 
* DCOS frameworks compatible
* [Vault] (http://vaultproject.io) for managing secrets
* [More registered](https://github.com/nixlike/ecore/issues)

## Quickstart (OS X) 

###Prerequesits:

* Vagrant 
* VirtualBox
* [Tunnelblick](https://tunnelblick.net/index.html)
* [DCOScli](http://docs.mesosphere.com/install/cli/) (optional)

###Get the code:

```
git clone git@github.com:nixlike/ecore.git 
```

### For Vagrant Local environment

1. Add vagrant box and start

```
$vagrant box add nixlike/ecoreallinone   
$cd envtype/vagrant/ && vagrant up  
```
2. Wait until the instance up up

3. Add Openvpn client config:  
```
Double click /tmp/vagrantshare/ADMIN.ovpn in Finder  
```
4. Connect Tunnelblick to ADMIN VPN  

5. Test:  

```
$ ping master.mesos   
PING master.mesos (172.17.8.101): 56 data bytes    
64 bytes from 172.17.8.101: icmp_seq=0 ttl=64 time=0.380 ms    
64 bytes from 172.17.8.101: icmp_seq=1 ttl=64 time=0.266 ms   
```
#### Via a browser 
Urls: [http://master.mesos:8080](http://master.mesos:8080) and [http://master.mesos:5050](http://master.mesos:5050)

####If you have DCOS installed, just use ./cli script
```
$ cd envtype/vagrant/
$ ./cli --help
```
### For AWS

1. Run  
`$cd ecore/envtype/aws/ && make apply`  

2. Wait until the environment is up

3. Add Openvpn client config
```
Double click /tmp/ADMIN.ovpn in "Finder"
```
4. Connect Tunnelblick to ADMIN VPN  
```
$ping master.mesos  
PING master.mesos (10.100.1.234): 56 data bytes  
64 bytes from 10.100.1.234: icmp_seq=0 ttl=62 time=103.687 ms  
64 bytes from 10.100.1.234: icmp_seq=1 ttl=62 time=86.273 ms  
64 bytes from 10.100.1.234: icmp_seq=2 ttl=62 time=87.391 ms  
```
#### Via a browser 
Urls: [http://master.mesos:8080](http://master.mesos:8080) and [http://master.mesos:5050](http://master.mesos:5050)

####If you have DCOS installed, just use ./cli script
```
$ cd ecore/envtype/aws/  
$ ./cli --help
```
####Most Terraform template variables can be amended in vars.tf !

