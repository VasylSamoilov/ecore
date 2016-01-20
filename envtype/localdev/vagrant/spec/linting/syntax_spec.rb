require 'spec_helper'

describe command('docker run -v $PWD/user-data:/tmp/user_data -i --entrypoint coreos-cloudinit steigr/coreos -validate --from-file /tmp/user_data') do
  its(:exit_status) { should eq 0 }
end

describe command('docker run -v $PWD/cli:/tmp/validate -i --entrypoint bash nixlike/buildcont:ubuntu-15.10 -n /tmp/validate') do
  its(:exit_status) { should eq 0 }
end

describe command('docker run -v $PWD/phase2init:/tmp/validate -i --entrypoint jsonlint nixlike/buildcont:ubuntu-15.10 -v /tmp/validate/memcached.json') do
  its(:exit_status) { should eq 0 }
end

describe command('docker run -v $PWD/Vagrantfile:/tmp/Vagrantfile -i --entrypoint ruby nixlike/buildcont:ubuntu-15.10 -c /tmp/Vagrantfile') do
  its(:exit_status) { should eq 0 }
end

