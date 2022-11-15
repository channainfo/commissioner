require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorJob do
  let(:vendor) { create(:active_vendor, name: 'vendor') }

  describe '#perform' do
    it 'invokes VendorUpdater.call' do
      expect(SpreeCmCommissioner::VendorUpdater).to receive(:call).with(vendor: vendor)
      described_class.new.perform(vendor.id)
    end
  end
end
