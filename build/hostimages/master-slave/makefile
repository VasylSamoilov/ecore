VERSION_ID := 884.0.0
CHANNEL    := alpha
CHECKSUM_TYPE   := md5
CHECKSUM   := e8fa0af4ae37ec3391b5a828dbfcda5c
AWS_REGION  := eu-west-1

FILES = \
	files/box/change_host_name.rb \
	files/box/configure_networks.rb \
	files/box/Vagrantfile \
	files/cloud-config.yml \
	files/coreos-setup-environment \
	files/install.yml \
	files/vagrant

box: coreos.json builds/virtualbox/coreos-$(CHANNEL).box $(FILES)

build: builds/virtualbox/coreos-$(CHANNEL).box ami

ami: 
	packer build -only=amazon-ebs -var-file=vars/vars.json -var "source_ami=`curl http://$(CHANNEL).release.core-os.net/amd64-usr/$(VERSION_ID)/coreos_production_ami_hvm_$(AWS_REGION).txt`" -var "aws_region=$(AWS_REGION)" -var "channel=$(CHANNEL)" -var "checksum=$(CHECKSUM)" -var "checksum_type=$(CHECKSUM_TYPE)" -var "version=$(VERSION_ID)" coreos.json

builds/virtualbox/coreos-$(CHANNEL).box:
	packer build -only=virtualbox-iso -var-file=vars/vars.json -var "channel=$(CHANNEL)" -var "checksum=$(CHECKSUM)" -var "checksum_type=$(CHECKSUM_TYPE)" -var "version=$(VERSION_ID)" coreos.json

install:
	vagrant box add --force --provider=virtualbox --name ecore/coreos-$(CHANNEL) builds/virtualbox/coreos-$(CHANNEL).box

clean:
	rm -fr builds
	rm -fr packer_cache

.PHONY: box ami clean build builds/virtualbox/coreos-$(CHANNEL).box
