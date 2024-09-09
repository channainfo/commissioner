require 'spec_helper'

RSpec.describe Spree::V2::Storefront::ProductSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:product) { create(:cm_product) }

    subject {
      described_class.new(product, params: { 'store': product.stores.first }, include: [
        :variants,
        :option_types,
        :product_properties,
        :taxons,
        :images,
        :default_variant,
        :primary_variant,
        :vendor,
        :variant_kind_option_types,
        :product_kind_option_types,
        :promoted_option_types,
        :possible_promotions,
        :default_state,
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
        :need_confirmation,
        :kyc,
        :product_type,
        :reveal_description,
        :allowed_upload_later,
        :allow_anonymous_booking,
        :discontinue_on,
        :use_video_as_default
      )
    end

    it 'returns exact taxon relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :variants,
        :option_types,
        :product_properties,
        :taxons,
        :images,
        :default_variant,
        :primary_variant,
        :vendor,
        :variant_kind_option_types,
        :product_kind_option_types,
        :promoted_option_types,
        :possible_promotions,
        :default_state,
        :venue
      )
    end
  end
end
