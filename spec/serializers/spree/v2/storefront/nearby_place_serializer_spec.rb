# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::NearbyPlaceSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:place) { create(:cm_place) }
    let(:vendor) { create(:vendor) }
    let(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

    context 'with no include' do
      subject { described_class.new(nearby_place).serializable_hash }

      it { expect(subject[:data][:attributes]).to include(:distance) }
      it { expect(subject[:data][:attributes]).to include(:position) }
      it { expect(subject[:data][:relationships]).to include(:vendor) }
      it { expect(subject[:data][:relationships]).to include(:place) }
    end

    context 'with include' do
      subject {
        described_class.new(nearby_place, include: [
          :vendor,
          :place
        ]).serializable_hash
      }

      it { expect(subject[:included].select {|e| e[:type] == :vendor}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :place}.size).to eq 1}
    end
  end
end
