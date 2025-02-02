require 'spec_helper'

describe Spree::V2::Tenant::AssetSerializer do
  describe '#serializable_hash' do
    let!(:asset) { create(:cm_asset) }

    subject {
      described_class.new(asset).serializable_hash
    }

    it 'returns exact asset attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :transformed_url,
        :alt,
        :original_url,
        :position,
        :styles
      )
    end

    it 'does not have relationships' do
      expect(subject[:data][:relationships]).to be nil
    end
  end
end
