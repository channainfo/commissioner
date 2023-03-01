require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NearbyPlacesLoaderJob do
  include ActiveJob::TestHelper
  let(:vendor) { create(:vendor , name: 'Villa vedici') }

  describe '#perform' do
    it 'invokes NearbyPlacesLoader.call' do
      expect(SpreeCmCommissioner::NearbyPlacesLoader).to receive(:call).with(vendor: vendor)
      described_class.new.perform(vendor.id)
    end
  end
end
