# spec/redis_spec.rb
require 'spec_helper'
require 'redis'

describe 'Redis Connection and Functionality' do
  let(:redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }

  before do
    # Ensure Redis is flushed before each test to avoid interference
    redis.flushdb
  end

  after do
    # Clean up Redis after each test
    redis.flushdb
    redis.quit
  end

  describe 'Redis connection' do
    it 'successfully connects to Redis' do
      expect { redis.ping }.not_to raise_error
      expect(redis.ping).to eq('PONG')
    end
  end

  describe 'Basic Redis functionality' do
    it 'sets and retrieves a key-value pair' do
      # Set a key-value pair
      redis.set('test_key', 'test_value')

      # Retrieve the value
      value = redis.get('test_key')

      expect(value).to eq('test_value')
    end
  end
end
