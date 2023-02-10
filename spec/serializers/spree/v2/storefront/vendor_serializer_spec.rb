# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::VendorSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:logo) { create(:vendor_logo) }
    let(:photo1) { create(:vendor_photo) }
    let(:vendor) { create(:vendor, logo: logo, photos: [ photo1 ]) }
    let(:stock_location1) { create(:cm_stock_location, vendor: vendor) }
    let(:place) { create(:cm_place) }
    let!(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

    context 'with no include' do
      subject { described_class.new(vendor).serializable_hash }

      it { expect(subject[:data][:attributes]).to include(:about_us) }
      it { expect(subject[:data][:attributes]).to include(:contact_us) }
      it { expect(subject[:data][:attributes]).to include(:name) }
      it { expect(subject[:data][:attributes]).to include(:slug) }
      it { expect(subject[:data][:attributes]).to include(:min_price) }
      it { expect(subject[:data][:attributes]).to include(:max_price) }
      it { expect(subject[:data][:attributes]).to include(:star_rating) }
      it { expect(subject[:data][:attributes]).to include(:short_description) }
      it { expect(subject[:data][:relationships]).to include(:image) }
      it { expect(subject[:data][:relationships]).to include(:logo) }
      it { expect(subject[:data][:relationships]).to include(:photos) }
      it { expect(subject[:data][:relationships]).to include(:products) }
      it { expect(subject[:data][:relationships]).to include(:stock_locations) }
      it { expect(subject[:data][:relationships]).to include(:vendor_kind_option_types) }
      it { expect(subject[:data][:relationships]).to include(:promoted_option_types) }
      it { expect(subject[:data][:relationships]).to include(:nearby_places) }
      it { expect(subject[:data][:relationships]).to include(:places) }
    end

    context 'with include' do
      subject {
        described_class.new(vendor, include: [
          :image,
          :logo,
          :photos,
          :products,
          :stock_locations,
          :nearby_places,
          :places
        ]).serializable_hash
      }

      it { expect(subject[:included].select {|e| e[:type] == :vendor_logo}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :photo}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :stock_location}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :nearby_place}.size).to eq 1}
      it { expect(subject[:included].select {|e| e[:type] == :place}.size).to eq 1}
    end
  end
end
