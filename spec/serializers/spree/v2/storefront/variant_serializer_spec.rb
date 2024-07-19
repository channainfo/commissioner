require 'spec_helper'

describe Spree::V2::Storefront::VariantSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:variant) { create(:cm_variant) }

    subject {
      described_class.new(variant, params: { 'store': variant.product.stores.first }, include: [
        :product,
        :images,
        :option_values,
        :vendor,
        :stock_items,
        :stock_locations
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
        :kyc,
        :need_confirmation,
        :product_type,
        :reminder_in_hours,
        :start_time,
        :max_quantity_per_order,
        :number_of_guests,
        :delivery_option,
        :delivery_required,
        :allow_anonymous_booking
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :product,
        :images,
        :option_values,
        :vendor,
        :stock_locations,
        :stock_items,
      )
    end

    it 'returns [included] with stock_items' do
      stock_items = subject[:included].filter { |item| item[:type] == :stock_item }

      expect(stock_items[0][:attributes][:count_on_hand]).to eq 0
      expect(stock_items[1][:attributes][:count_on_hand]).to eq 0
    end
  end
end
