require 'rubygems'
require 'bundler'
require 'rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

task :build do
  require_relative 'lib/est'
  `bundle exec jekyll clean`
  `bundle exec jekyll build`
  EST.build Pathname.new(File.expand_path('../', __FILE__))
end
