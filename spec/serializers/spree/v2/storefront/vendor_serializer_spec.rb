# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::VendorSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:vendor) {
      stock_location = create(:stock_location)

      vendor = build(:vendor)
      vendor.stock_locations = [stock_location]
      vendor.save!
      vendor.reload
    }

    subject { described_class.new(vendor).serializable_hash }

    it { expect(subject[:data][:attributes]).to include(:about_us) }
    it { expect(subject[:data][:attributes]).to include(:contact_us) }
    it { expect(subject[:data][:attributes]).to include(:name) }
    it { expect(subject[:data][:attributes]).to include(:slug) }
    it { expect(subject[:data][:attributes]).to include(:min_price) }
    it { expect(subject[:data][:attributes]).to include(:max_price) }

    it { expect(subject[:data][:relationships]).to include(:image) }
    it { expect(subject[:data][:relationships]).to include(:logo) }
    it { expect(subject[:data][:relationships]).to include(:products) }
    it { expect(subject[:data][:relationships]).to include(:stock_locations) }
  end
end
