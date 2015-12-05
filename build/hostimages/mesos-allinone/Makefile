COREOS_V=884.0.0

download:
	wget  -c -O packer_cache/coreos_production_virtualbox.ovf http://alpha.release.core-os.net/amd64-usr/$(COREOS_V)/coreos_production_virtualbox.ovf
	wget  -c -O packer_cache/coreos_production_virtualbox_image.vmdk.bz2 http://alpha.release.core-os.net/amd64-usr/$(COREOS_V)/coreos_production_virtualbox_image.vmdk.bz2
clean:
	rm -rf packer_cache/*
