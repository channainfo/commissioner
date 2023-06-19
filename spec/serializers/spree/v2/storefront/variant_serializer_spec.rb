require 'spec_helper'

describe Spree::V2::Storefront::VariantSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:variant) { create(:cm_variant) }

    subject {
      described_class.new(variant, params: { 'store': variant.product.stores.first }, include: [
        :product,
        :images,
        :option_values,
        :vendor
      ]).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :sku,
        :barcode,
        :weight,
        :height,
        :width,
        :depth,
        :is_master,
        :options_text,
        :public_metadata,
        :purchasable,
        :in_stock,
        :backorderable,
        :currency,
        :price,
        :display_price,
        :compare_at_price,
        :display_compare_at_price,
        :permanent_stock
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :product,
        :images,
        :option_values,
        :vendor
      )
    end
  end
end
