require 'spec_helper'

#Minimal test for an instance during provision
describe command(' "cd ecore/envtype/CI && rake" 2>&1 ') do
                   its(:exit_status) { should eq 0 }
end
