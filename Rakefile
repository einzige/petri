require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs      << 'lib' << 'test'
  test.pattern   = 'test/**/*_test.rb'
end

desc 'Run tests'
task :default => :test
