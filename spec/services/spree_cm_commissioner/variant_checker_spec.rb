require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantChecker do
  let!(:product) { create(:product, name: "Island Waste Collection") }
  let!(:option_types) { [create(:option_type, name: "Month"), create(:option_type, name: "Due Date"), create(:option_type, name: "Payment Method")] }
  let!(:option_values) { [create(:option_value, name: "1", id: 1, option_type: option_types[0]), create(:option_value, name: "1", id: 2, option_type: option_types[1]), create(:option_value, name: "pre-paid", id: 3, option_type: option_types[2])] }
  let!(:variant_params) { { product_id: product.id, option_value_ids: option_values.map(&:id), price: 10.0 } }
  let!(:current_vendor) { create(:vendor) }

  describe '#find_or_create_variant' do
    context 'when the variant already exists' do
      let!(:variant1) { SpreeCmCommissioner::VariantCreator.new(product, variant_params, current_vendor).create_variant }

      it 'returns the existing variant' do
        variant_checker = described_class.new(variant_params, current_vendor)
        variant = variant_checker.find_or_create_variant
        expect(variant).to be_a Spree::Variant
        expect(variant).to eq(variant1)
      end
    end

    context 'when the variant does not exist' do
      it 'creates a new variant' do
        variant_checker = described_class.new(variant_params, current_vendor)
        allow(variant_checker).to receive(:find_variant_by_sku)
        expect(variant_checker.send(:find_variant_by_sku)).to eq nil

        variant = variant_checker.find_or_create_variant
        expect(variant).to be_a Spree::Variant
      end
    end
  end
end
