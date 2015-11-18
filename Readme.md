# Ecore
Not because of the hype, but because I love it!

##Objectives

* The easiest way to rollout local mesos platform
* Cloud Agnostic
* Resource capacity is the only difference between environments
* No static particioning 
* Security applied starting from DEV
* Scallability and HA out of the box

##Build blocks

* [Terraform](https://terraform.io) for real infrastructure as a code
* [CoreOS](https://coreos.com) as a minimalistic basement of any host
* [Docker](https://www.docker.com) for anything else
* [Mesos](http://mesos.apache.org) a distribuited cluster kernel
* [Kubernetes](http://kubernetes.io) for the best docker orchestration
* [Vault] (http://vaultproject.io) for managing secrets
* [Consul](http://consul.io) for service discovery 
* More coming ...

## Already available features

Local vagrant single node environment with latest:
* CoreOS
* Zookeeper
* Mesos master 
* Mesos slave
* Consul
* Mesos consul
* DCOS cli

## Quickstart 

*Prerequesits:*

* Vagrant 
* [DCOS cli](http://docs.mesosphere.com/install/cli/),optional

*Get the code:*

```
git clone git@github.com:nixlike/ecore.git && cd ecore/envtype/localdev/vagrant
git submodule init 
git submodule update
```

*Create folder for docker images persistance (can be amended to alterantive in config.rb):*

```
mkdir /tmp/ecore 
```

*Run the box:*

```
vagrant up
```

*Before using, make a cofee until docker is pulling images*

## USE

*If you have DCOS installed, just use ./cli script*

```
$ ./cli --help
Command line utility for the Mesosphere Datacenter Operating
System (DCOS)

'dcos help' lists all available subcommands. See 'dcos <command> --help'
to read about a specific subcommand.

Usage:
    dcos [options] [<command>] [<args>...]
```

*Reach mesos and marathon natively also http://mesos_ip:5050 and http://mesos_ip:8080 respectively*
*Obtain mesos ip as below:*

```
vagrant ssh -c 'docker inspect mesos-master|egrep MESOS_IP|tr -d \"\,'|awk -F= '{print $2}'
```
