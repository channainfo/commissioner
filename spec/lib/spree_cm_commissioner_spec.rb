require 'spec_helper'

RSpec.describe SpreeCmCommissioner do
  before { described_class.reset_redis_pool }

  describe '.redis_pool' do
    it 'returns a ConnectionPool instance' do
      expect(described_class.redis_pool).to be_a(ConnectionPool)
    end

    it 'memoizes the pool instance' do
      first_pool = described_class.redis_pool
      second_pool = described_class.redis_pool
      expect(first_pool).to be(second_pool)
    end
  end

  describe '.redis_pool=' do
    it 'allows setting a custom pool' do
      custom_pool = double('custom_pool')
      described_class.redis_pool = custom_pool
      expect(described_class.redis_pool).to eq(custom_pool)
    end
  end

  describe '.reset_redis_pool' do
    it 'resets the pool to nil' do
      # First access to initialize the pool
      described_class.redis_pool
      described_class.reset_redis_pool
      expect(described_class.instance_variable_get(:@redis_pool)).to be_nil
    end
  end

  describe '.default_redis_pool' do
    context 'with default environment variables' do
      it 'uses default values' do
        allow(ENV).to receive(:fetch).with('REDIS_POOL_SIZE', '5').and_return('5')
        allow(ENV).to receive(:fetch).with('REDIS_TIMEOUT', '5').and_return('5')
        allow(ENV).to receive(:fetch).with('REDIS_URL', 'redis://localhost:6379/12')
          .and_return('redis://localhost:6379/12')

        pool = described_class.send(:default_redis_pool)
        expect(pool.instance_variable_get(:@size)).to eq(5)
        expect(pool.instance_variable_get(:@timeout)).to eq(5)
      end
    end

    context 'with custom environment variables' do
      around do |example|
        ENV['REDIS_POOL_SIZE'] = '10'
        ENV['REDIS_TIMEOUT'] = '3'
        ENV['REDIS_URL'] = 'redis://custom:6380/1'
        example.run
        ENV.delete('REDIS_POOL_SIZE')
        ENV.delete('REDIS_TIMEOUT')
        ENV.delete('REDIS_URL')
      end

      it 'uses environment variable values' do
        pool = described_class.send(:default_redis_pool)
        expect(pool.instance_variable_get(:@size)).to eq(10)
        expect(pool.instance_variable_get(:@timeout)).to eq(3)
      end
    end
  end

  describe '.configure' do
    it 'yields self to the block' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class)
    end
  end
end
