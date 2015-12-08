COREOS_V=884.0.0
VBOX_NAME=coreos_production_virtualbox

.PHONY: download configdrive 

download:
	wget --no-use-server-timestamps -c -O packer_cache/$(VBOX_NAME).ovf http://alpha.release.core-os.net/amd64-usr/$(COREOS_V)/$(VBOX_NAME).ovf
	wget --no-use-server-timestamps -c -O packer_cache/$(VBOX_NAME)_image.vmdk.bz2 http://alpha.release.core-os.net/amd64-usr/$(COREOS_V)/$(VBOX_NAME)_image.vmdk.bz2
	[ ! packer_cache/$(VBOX_NAME)_image.vmdk -ot packer_cache/$(VBOX_NAME)_image.vmdk.bz2 ] || [ ! -e packer_cache/$(VBOX_NAME)_image.vmdk ] && bzip2 -f -k -d packer_cache/$(VBOX_NAME)_image.vmdk.bz2

configdrive:
	[ -f files/configdrive.iso ] && rm files/configdrive.iso
	hdiutil makehybrid -iso -joliet -default-volume-name config-2 -o ./files/configdrive.iso ./configdrive

build:
	packer build --force packer.json && vagrant box add --name coreos_packer --force files/coreos.box

clean:
	rm -rf packer_cache/*
