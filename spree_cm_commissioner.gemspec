lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_cm_commissioner/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cm_commissioner'
  s.version     = SpreeCmCommissioner.version
  s.summary     = 'Add extension summary here'
  s.description = 'Add (optional) extension description here'
  s.required_ruby_version = '>= 2.7'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_cm_commissioner'
  s.license = 'BSD-3-Clause'

  s.files = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(%r{^spec/fixtures})}

  s.require_path = 'lib'
  s.requirements << 'none'

  spree_opts = '>= 4.5.0'
  s.add_dependency 'spree', spree_opts
  s.add_dependency 'spree_api_v1', spree_opts # latest spree_multi_vendor 2.4.0 still depends on the Spree v1 API
  s.add_dependency 'spree_auth_devise', spree_opts
  s.add_dependency 'spree_backend', spree_opts
  s.add_dependency 'spree_multi_vendor', '>= 2.4.1'
  s.add_dependency 'spree_extension'

  s.add_dependency 'activerecord-multi-tenant'
  s.add_dependency 'phonelib'
  s.add_dependency 'aws-sdk-ecs'
  s.add_dependency 'google-cloud-firestore'
  s.add_dependency 'google-cloud-recaptcha_enterprise'
  s.add_dependency 'jwt', '>= 2.5.0'
  s.add_dependency 'elasticsearch', '~> 8.5'
  s.add_dependency 'interactor', '~> 3.1'
  s.add_dependency 'rails', '~> 7.0.4'
  s.add_dependency 'searchkick', '~> 5.1'
  s.add_dependency 'twilio-ruby', '~> 5.48.0'
  s.add_dependency 'dry-validation', '~> 1.10'
  s.add_dependency 'byebug'
  s.add_dependency 'font-awesome-sass', '~> 6.4.0'
  s.add_dependency 'noticed', '~> 1.6'
  s.add_dependency 'aws-sdk-s3'
  s.add_dependency 'aws-sdk-cloudfront'
  s.add_dependency 'simple_calendar', '~> 2.4'
  s.add_dependency 'activerecord_json_validator', '~> 2.1', '>= 2.1.3'
  s.add_dependency 'googleauth'
  s.add_dependency 'telegram-bot'
  s.add_dependency 'exception_notification'
  s.add_dependency "rqrcode", "~> 2.0"
  s.add_dependency "premailer-rails"
  s.add_dependency 'counter_culture', '~> 3.2'
  # Redis
  s.add_dependency 'redis'
  s.add_dependency 'redis-rails'
  s.add_dependency 'connection_pool'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'spree_dev_tools'
  s.metadata['rubygems_mfa_required'] = 'true'
end
