require 'spec_helper'

RSpec.describe Spree::V2::Storefront::PlaceSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:place) { create(:cm_place) }
    let!(:vendor) { create(:vendor) }
    let!(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

    subject {
      described_class.new(place, include: [
        :vendors,
        :nearby_places
      ]).serializable_hash
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

    it 'returns exact taxon relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :vendors,
        :nearby_places
      )
    end
  end
end
