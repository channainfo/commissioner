require 'spec_helper'

RSpec.describe Spree::V2::Storefront::NearbyPlaceSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:place) { create(:cm_place) }
    let!(:vendor) { create(:vendor) }
    let!(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

    subject {
      described_class.new(nearby_place, include: [
        :vendor,
        :place
      ]).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :distance,
        :position
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :vendor,
        :place
      )
    end
  end
end
