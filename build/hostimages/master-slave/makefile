VERSION_ID := 1.0.0
CHANNEL    := alpha

FILES = \
	files/box/change_host_name.rb \
	files/box/configure_networks.rb \
	files/box/Vagrantfile \
	files/cloud-config.yml \
	files/coreos-setup-environment \
	files/install.yml \
	files/vagrant

box: coreos.json builds/virtualbox/coreos-$(CHANNEL).box $(FILES)

build: builds/virtualbox/coreos-$(CHANNEL).box

ami: 
	packer build -only=amazon-ebs -var-file=vars/ami.json -var "source_ami=`curl http://beta.release.core-os.net/amd64-usr/899.6.0/coreos_production_ami_hvm_eu-west-1.txt`" coreos.json

builds/virtualbox/coreos-$(CHANNEL).box:
	packer build -only=virtualbox-iso coreos.json

install:
	vagrant box add --force --provider=virtualbox --name ecore/coreos-$(CHANNEL) builds/virtualbox/coreos-$(CHANNEL).box

clean:
	rm -fr builds
	rm -fr packer_cache

.PHONY: box clean build builds/virtualbox/coreos-$(CHANNEL).box
