require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantCreator do
  describe '#create_variant' do
    let(:product) { create(:product, name: "Waste Collection") }
    let(:option_types) { [create(:option_type, name: "Month"), create(:option_type, name: "Due Date"), create(:option_type, name: "Payment Method")] }
    let(:option_values) { [create(:option_value, name: "1", id: 1, option_type: option_types[0]), create(:option_value, name: "1", id: 2, option_type: option_types[1]), create(:option_value, name: "pre-paid", id: 3, option_type: option_types[2])] }
    let(:variant_params) { { product_id: product.id, option_value_ids: option_values.map(&:id), price: 10.0 } }
    let(:sku_generator) { described_class.new(product, variant_params) }
    let(:current_vendor) { create(:vendor) }

    it 'creates a variant with the expected attributes' do
      variant_creator = SpreeCmCommissioner::VariantCreator.new(product, variant_params, current_vendor)
      variant = variant_creator.create_variant

      expect(variant.sku).to eq("waste-collection-month-1-due-date-1-payment-method-pre-paid-price-10.0")
      expect(variant.option_value_ids).to eq([1, 2, 3])
      expect(variant.price).to eq(10)
      expect(variant.stock_items.first.count_on_hand).to eq(1)
    end
  end
end
