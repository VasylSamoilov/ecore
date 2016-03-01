require 'spec_helper'

#Temprorary disabled due to bug in hadolint, reported
#describe command('docker run --rm -i lukasmartinelli/hadolint < $PWD/build/buildcont/Dockerfile') do
#	  its(:exit_status) { should eq 0 }
#end

#all json linting
describe command('docker run --rm -i --entrypoint bash -v $PWD:/tmp/validate nixlike/buildcont:ubuntu-15.10 -c \'find validate/ -name "*.json"|xargs jsonlint\' 2 >&1') do
	  its(:stdout) { should_not match /Error/ }
end

#User data validation
describe command('docker run --rm -v $PWD/envtype/vagrant/user-data:/tmp/user_data -i --entrypoint coreos-cloudinit steigr/coreos -validate --from-file /tmp/user_data') do
	  its(:exit_status) { should eq 0 }
end

#Vagrant server cli syntax check
describe command('docker run --rm -v $PWD/envtype/vagrant/cli:/tmp/validate -i --entrypoint shellcheck nixlike/buildcont:ubuntu-15.10 /tmp/validate') do
	  its(:stdout) { should_not match /SC/ }
end

#Vagrant server cli linting
describe command('docker run --rm -v $PWD/envtype/vagrant/cli:/tmp/validate -i --entrypoint bash nixlike/buildcont:ubuntu-15.10 -n /tmp/validate') do
	  its(:exit_status) { should eq 0 }
end

#Vagrant file syntax check
describe command('docker run --rm -v $PWD/envtype/vagrant/Vagrantfile:/tmp/Vagrantfile -i --entrypoint ruby nixlike/buildcont:ubuntu-15.10 -c /tmp/Vagrantfile') do
	  its(:exit_status) { should eq 0 }
end


# Syntax check for all ruby scrips (not too reliable, plan linter )
describe command('docker run --rm -i --entrypoint bash -v $PWD:/tmp/validate nixlike/buildcont:ubuntu-15.10 -c \'find validate/ -name "*.rb"|xargs ruby -c\' 2 >&1') do
	  its(:stdout) { should_not match /error/ }
end

#Linting all shell scripts in the repo
describe command('docker run --rm -i --entrypoint bash -v $PWD:/tmp/validate nixlike/buildcont:ubuntu-15.10 -c \'find validate/ -name "*.sh"|xargs shellcheck\' 2 >&1') do
	  its(:stdout) { should_not match /SC/ }
end
