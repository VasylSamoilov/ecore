require 'spec_helper'

describe command('docker run -v $PWD/user-data:/tmp/user_data -i --entrypoint coreos-cloudinit steigr/coreos -validate --from-file /tmp/user_data') do
  its(:exit_status) { should eq 0 }
end

describe command('docker run -v $PWD/cli:/tmp/validate -i --entrypoint bash ubuntu -n /tmp/validate') do
  its(:exit_status) { should eq 0 }
end

describe command('docker run -v $PWD/phase2init:/tmp/validate -i --entrypoint jsonlint nixlike/buildcont:ubuntu-14.04 /tmp/validate/memcached.json') do
  its(:exit_status) { should eq 0 }
end
