desc "Run all spec examples"
begin
  ENV["RAILS_ENV"] = 'test'

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
