# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_cm_commissioner/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cm_commissioner'
  s.version     = SpreeCmCommissioner.version
  s.summary     = 'Add extension summary here'
  s.description = 'Add (optional) extension description here'
  s.required_ruby_version = '>= 2.5'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_cm_commissioner'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'rails', '~> 6.1.4'
  s.add_dependency 'jwt'

  s.add_development_dependency 'spree_dev_tools'
  s.add_development_dependency 'pg'
end
