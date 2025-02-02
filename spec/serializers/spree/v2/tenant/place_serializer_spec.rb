require 'spec_helper'

RSpec.describe Spree::V2::Tenant::PlaceSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:place) { create(:cm_place) }

    subject {
      described_class.new(place).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :reference,
        :name,
        :vicinity,
        :lat,
        :lon,
        :icon,
        :url,
        :rating,
        :formatted_phone_number,
        :formatted_address,
        :address_components,
        :types
      )
    end
  end
end
