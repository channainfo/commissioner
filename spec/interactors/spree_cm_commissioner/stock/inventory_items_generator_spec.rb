require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::InventoryItemsGenerator, type: :interactor do
  describe '#call' do
    let(:variant) { create(:cm_variant) }
    let(:context) { described_class.call(variant: variant) }

    context 'when variant is permanent stock' do
      let(:variant) { create(:cm_variant, product_type: 'accommodation', pregenerate_inventory_items: false) } # accommodation is permanent stock
      before do
        allow_any_instance_of(Spree::Variant).to receive(:pre_inventory_days).and_return(2)
      end

      it 'calls PermanentInventoryItemsGenerator with the variant ID' do
        expect(SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator)
          .to receive(:call).with(variant_ids: [variant.id]).and_call_original
        expect(variant).not_to receive(:create_default_non_permanent_inventory_item!)

        context

        expect(variant.reload.inventory_items.count).to eq(2)
      end
    end

    context 'when variant is not permanent stock' do
      let(:variant) { create(:cm_variant, product_type: 'ecommerce', pregenerate_inventory_items: false) } #  is permanent stock

      context 'when default inventory item does not exist' do

        it 'calls create_default_non_permanent_inventory_item!' do
          expect(variant).to receive(:create_default_non_permanent_inventory_item!)
          expect(variant.default_inventory_item_exist?).to be false

          context
        end

        it 'does not call PermanentInventoryItemsGenerator' do
          expect(SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator).not_to receive(:call)

          context
        end
      end

      context 'when default inventory item exists' do
        let(:variant) { create(:cm_variant, product_type: 'ecommerce', pregenerate_inventory_items: true) } #  is permanent stock

        it 'does not call create_default_non_permanent_inventory_item!' do
          expect(variant).not_to receive(:create_default_non_permanent_inventory_item!)
          expect(variant.default_inventory_item_exist?).to be true
          expect(SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator).not_to receive(:call)

          context
        end
      end
    end
  end
end
