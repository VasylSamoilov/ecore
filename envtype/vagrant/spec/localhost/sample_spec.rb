require 'spec_helper'

#Minimal check for running mesos marathon
describe command('./cli marathon about') do
	          its(:stdout) { should match /"elected": true/ }
end
