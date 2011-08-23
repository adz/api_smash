# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

#require 'api_smash/version'

Gem::Specification.new do |s|
  s.name        = "api_smash"
  s.version     = "1.0.0" #ApiSmash::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Darcy Laycock", "Steve Webb"]
  s.email       = ["sutto@thefrontiergroup.com.au"]
  s.homepage    = "http://github.com/thefrontiergroup"
  s.summary     = "A dash with transformers"
  s.description = "Hashie dash api_smash"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency 'hashie',   '~> 1.0'

  s.add_development_dependency 'rr'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'fuubar'

  s.files        = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
end
