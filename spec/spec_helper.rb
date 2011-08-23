ENV["RAILS_ENV"] ||= 'test'

require 'rspec'

require 'pathname'
require 'bundler/setup'

Bundler.setup
Bundler.require :default, :test

require 'api_smash'
require 'rr'

RSpec.configure do |config|
  config.mock_with :rr
end