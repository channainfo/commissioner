require 'spec_helper'

RSpec.describe Spree::V2::Tenant::ProductSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:product) { create(:cm_product) }

    subject {
      described_class.new(product, params: { 'store': product.stores.first }, include: [
        :venue,
        :product_properties,
        :taxons,
        :images,
        :default_variant,
        :primary_variant,
        :variant_kind_option_types,
        :product_kind_option_types,
        :promoted_option_types,
        :possible_promotions,
        :default_state,
        :variants,
        :option_types
      ]).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :description,
        :available_on,
        :slug,
        :meta_description,
        :meta_keywords,
        :updated_at,
        :sku,
        :barcode,
        :public_metadata,
        :purchasable,
        :in_stock,
        :backorderable,
        :available,
        :currency,
        :price,
        :display_price,
        :compare_at_price,
        :display_compare_at_price,
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :venue,
        :product_properties,
        :taxons,
        :images,
        :default_variant,
        :primary_variant,
        :variant_kind_option_types,
        :product_kind_option_types,
        :promoted_option_types,
        :possible_promotions,
        :default_state,
        :variants,
        :option_types
      )
    end
  end
end
