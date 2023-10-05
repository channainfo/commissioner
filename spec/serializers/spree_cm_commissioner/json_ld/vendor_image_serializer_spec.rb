require 'spec_helper'

RSpec.describe SpreeCmCommissioner::JsonLd::VendorImageSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:vendor_image) { create(:vendor_image) }

    subject {
      described_class.new(vendor_image).serializable_hash
    }

    it 'returns exact asset attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :url
      )
    end
  end
end
