require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SkuGenerator do
  let(:product) { create(:product, name: "Waste Collection") }
  let(:option_types) { [create(:option_type, name: "Month"), create(:option_type, name: "Due Date"), create(:option_type, name: "Payment Method")] }
  let(:option_values) { [create(:option_value, name: "1", option_type: option_types[0]), create(:option_value, name: "1", option_type: option_types[1]), create(:option_value, name: "pre-paid", option_type: option_types[2])] }
  let(:variant_params) { { product_id: product.id, option_value_ids: option_values.map(&:id), price: 10.0 } }
  let(:sku_generator) { described_class.new(product, variant_params) }

  describe '.generate_sku' do
    it 'returns the generated sku' do
      generated_sku = sku_generator.generate_sku

      expect(generated_sku).to eq "waste-collection-month-1-due-date-1-payment-method-pre-paid-price-10.0"
    end
  end
end
