require 'spec_helper'

RSpec.describe Spree::V2::Storefront::AccommodationSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:logo) { create(:vendor_logo) }
    let!(:photo1) { create(:vendor_photo) }
    let!(:vendor) { create(:vendor, logo: logo, photos: [ photo1 ]) }
    let!(:stock_location1) { create(:cm_stock_location, vendor: vendor) }

    subject {
      described_class.new(vendor.reload, include: [
        :image,
        :products,
        :stock_locations,
        :variants,
        :photos,
        :vendor_kind_option_types,
        :promoted_option_types,
        :nearby_places,
        :places,
        :promoted_option_values,
        :vendor_kind_option_values,
        :active_promotions,
        :logo,
      ]).serializable_hash
    }

    it 'returns exact accommodations attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :about_us,
        :slug,
        :contact_us,
        :min_price,
        :max_price,
        :star_rating,
        :short_description,
        :total_inventory,
        :service_availabilities,
        :total_booking,
        :remaining
      )
    end

    it 'returns exact accommodation relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :image,
        :products,
        :stock_locations,
        :variants,
        :photos,
        :vendor_kind_option_types,
        :promoted_option_types,
        :nearby_places,
        :places,
        :promoted_option_values,
        :vendor_kind_option_values,
        :active_promotions,
        :logo,
        :state
      )
    end
  end
end
