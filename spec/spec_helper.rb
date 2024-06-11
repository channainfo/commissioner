# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'spree_dev_tools/rspec/spec_helper'
require 'spree_multi_vendor/factories'
require 'spree_cm_commissioner/factories'
require 'interactor'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.include ActiveRecord
  config.include Helper
  config.include DoorkeeperAuthHelper
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :request

  # Encryption key for active record
  # Ref: https://guides.rubyonrails.org/active_record_encryption.html
  config.active_record.encryption.primary_key = "WwpSk7hO246PEo4ydZtRoZb8VALb4b6P"
  config.active_record.encryption.deterministic_key = "iQ6lqIgcxbdpdw4Utm5nltHYh51HlNx7"
  config.active_record.encryption.key_derivation_salt = "17IetNIDQK4XmEcq6Ob6wUKcmiKf9nXg"

  # https://github.com/channainfo/commissioner/pull/316
  config.order = :random
  Kernel.srand config.seed
end
