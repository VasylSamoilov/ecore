require 'spec_helper'

describe command('docker run -v $PWD/user-data:/tmp/user_data -i --entrypoint coreos-cloudinit steigr/coreos -validate --from-file /tmp/user_data') do
  its(:exit_status) { should eq 0 }
end
