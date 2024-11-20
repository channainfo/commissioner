require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InvalidateCacheRequest do
  before do
    ENV['AWS_REGION'] = 'ap-southeast-1'
    ENV['AWS_ACCESS_KEY_ID'] = 'AXXXXXXXXXXXXXXXY'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'VO103FAKEFAKEFAKE3020X=I230x1'
    ENV['ASSETS_SYNC_CF_DIST_ID'] = 'D12FAKEFAKE'
  end

  describe '.call', :vcr do
    it 'requested to invalidate cache & return response' do
      context = described_class.call(pattern: '/staging/422.html')

      expect(context.response.location).to eq "https://cloudfront.amazonaws.com/2020-05-31/distribution/D12FAKEFAKE/invalidation/I2PGO1F2LAWEKXXYAKMN0P38N1"
      expect(context.response.invalidation.id).to eq "I2PGO1F2LAWEKXXYAKMN0P38N1"
      expect(context.response.invalidation.status).to eq "InProgress"
    end
  end
end
