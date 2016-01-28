require 'rake'
require 'rspec/core/rake_task'

task :glob    => 'glob:lint'
task :default => :glob
task :vagrant => 'vagrant:all'

namespace :glob do
  targets = []
  Dir.glob('./spec/lint/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :lint     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/lint/#{original_target}/*_spec.rb"
    end
  end
end

namespace :vagrant do
  task :all do
	  sh "cd envtype/localdev/vagrant&&rake"
  end
end
