require 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'pry'
require 'rack/jekyll'
require 'rack/test'
require 'support/build_hooks'


RSpec.configure do |_config|
  Capybara.javascript_driver = :poltergeist
  Capybara.default_max_wait_time = 10
  Capybara.app = Rack::Jekyll.new force_build: true
end
