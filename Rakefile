#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Workarea3 Plugin'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('../test/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'
load 'workarea/changelog.rake'

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end


task default: :test

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'workarea/paypal/version'

desc "Release version #{Workarea::Paypal::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"

  Rake::Task['workarea:changelog'].execute
  system 'git add CHANGELOG.md'
  system 'git commit -m "Update CHANGELOG"'

  system "git tag -a v#{Workarea::Paypal::VERSION} -m 'Tagging #{Workarea::Paypal::VERSION}'"
  system 'git push origin HEAD --follow-tags'

  system 'gem build workarea-paypal.gemspec'
  system "gem push workarea-paypal-#{Workarea::Paypal::VERSION}.gem"
  system "gem push workarea-paypal-#{Workarea::Paypal::VERSION}.gem --host #{host}"
  system "rm workarea-paypal-#{Workarea::Paypal::VERSION}.gem"
end
