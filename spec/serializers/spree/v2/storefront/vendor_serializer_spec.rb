require 'spec_helper'

RSpec.describe Spree::V2::Storefront::VendorSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:vendor) { create(:vendor) }

    subject {
      described_class.new(vendor, include: [
        :image,
        :logo,
        :photos,
        :products,
        :stock_locations,
        :nearby_places,
        :places,
        :default_state,
      ]).serializable_hash
    }

    it 'returns exact vendor attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :about_us,
        :slug,
        :contact_us,
        :min_price,
        :max_price,
        :star_rating,
        :short_description,
        :full_address
      )
    end

    it 'returns exact vendor relationships' do
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
        :default_state,
        :logo
      )
    end
  end
end
