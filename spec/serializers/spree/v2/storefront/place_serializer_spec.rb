# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::PlaceSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:place) { create(:cm_place) }
    let(:vendor) { create(:vendor) }
    let!(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

    context 'with no include' do
      subject { described_class.new(place).serializable_hash }

      it { expect(subject[:data][:attributes]).to include(:name) }
      it { expect(subject[:data][:attributes]).to include(:vicinity) }
      it { expect(subject[:data][:attributes]).to include(:lat) }
      it { expect(subject[:data][:attributes]).to include(:lon) }
      it { expect(subject[:data][:attributes]).to include(:icon) }
      it { expect(subject[:data][:attributes]).to include(:url) }
      it { expect(subject[:data][:attributes]).to include(:rating) }
      it { expect(subject[:data][:attributes]).to include(:formatted_phone_number) }
      it { expect(subject[:data][:attributes]).to include(:formatted_address) }
      it { expect(subject[:data][:attributes]).to include(:address_components) }
      it { expect(subject[:data][:attributes]).to include(:types) }
      it { expect(subject[:data][:relationships]).to include(:vendors) }
      it { expect(subject[:data][:relationships]).to include(:nearby_places) }
    end

    context 'with include' do
      subject {
        described_class.new(place, include: [
          :vendors,
          :nearby_places
        ]).serializable_hash
      }

      it { expect(subject[:included].select {|e| e[:type] == :vendor}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :nearby_place}.size).to eq 1}
    end
  end
end
