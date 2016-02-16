require 'spec_helper'

#Minimal test for an instance during provision
describe command('docker run --entrypoint bash nixlike/buildcont:ubuntu-15.10 -c "cd ecore/envtype/CI && rake" ') do
                  its(:stdout) { should not match /Error/ }
end
