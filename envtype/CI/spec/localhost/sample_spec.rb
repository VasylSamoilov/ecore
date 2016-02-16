require 'spec_helper'

#Minimal test for an instance during provision
describe command('curl -f http://leader.mesos:5050/master/health 2>&1') do
                   its(:exit_status) { should eq 0 }
end
