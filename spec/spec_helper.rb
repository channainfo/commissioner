# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'spree_dev_tools/rspec/spec_helper'
require 'spree_multi_vendor/factories'
require 'spree_cm_commissioner/factories'
require 'interactor'
require 'blazer'

DatabaseCleaner.allow_remote_database_url = true if Rails.env.test?

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.include Helper
  config.include DoorkeeperAuthHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :request
  config.include ActiveJob::TestHelper
  # https://github.com/channainfo/commissioner/pull/316
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    SpreeCmCommissioner.redis_pool.with do |redis|
      begin
        redis.flushdb
      rescue Redis::CannotConnectError => e
        Rails.logger.warn("Redis not available: #{e.message}")
      end
    end
  end
end
