require 'spec_helper'

#Temprorary disabled due to bug in hadolint, reported
#describe command('docker run --rm -i lukasmartinelli/hadolint < $PWD/build/buildcont/Dockerfile') do
#	  its(:exit_status) { should eq 0 }
#end

describe command('docker run --rm -i --entrypoint bash -v $PWD:/tmp/validate nixlike/buildcont:ubuntu-15.10 -c \'find validate/ -name "*.json"|xargs jsonlint\' 2 >&1') do
	  its(:stdout) { should_not match /Error/ }
end

describe command('docker run --rm -v $PWD/envtype/localdev/vagrant/user-data:/tmp/user_data -i --entrypoint coreos-cloudinit steigr/coreos -validate --from-file /tmp/user_data') do
	  its(:exit_status) { should eq 0 }
end

describe command('docker run --rm -v $PWD/envtype/localdev/vagrant/cli:/tmp/validate -i --entrypoint bash nixlike/buildcont:ubuntu-15.10 -n /tmp/validate') do
	  its(:exit_status) { should eq 0 }
end

describe command('docker run --rm -v $PWD/envtype/localdev/vagrant/Vagrantfile:/tmp/Vagrantfile -i --entrypoint ruby nixlike/buildcont:ubuntu-15.10 -c /tmp/Vagrantfile') do
	  its(:exit_status) { should eq 0 }
end

describe command('docker run --rm -i --entrypoint bash -v $PWD:/tmp/validate nixlike/buildcont:ubuntu-15.10 -c \'find validate/ -name "*.rb"|xargs ruby -c\' 2 >&1') do
	  its(:stdout) { should_not match /error/ }
end
