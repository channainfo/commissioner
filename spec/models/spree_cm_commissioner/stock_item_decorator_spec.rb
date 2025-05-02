require 'spec_helper'

RSpec.describe SpreeCmCommissioner::StockItemDecorator, type: :model do
  let(:stock_location) { create(:stock_location) }
  let(:product_type) { 'ecommerce' }
  let(:product) { create(:product, product_type: product_type) }
  let(:variant) { create(:variant, product: product, is_master: false) }
  let(:stock_item) { create(:stock_item, variant: variant, stock_location: stock_location, count_on_hand: 0) }

  describe '#create_inventory_items' do
    context 'when creating a new stock item' do
      context 'with permanent stock product type' do
        let(:product_type) { 'accommodation' } # Permanent stock

        it 'enqueues PermanentInventoryItemsGeneratorJob with variant id' do
          expect(SpreeCmCommissioner::Stock::PermanentInventoryItemsGeneratorJob)
            .to receive(:perform_later).with(variant_ids: [variant.id])
          stock_item
        end

        it 'does not call create_default_non_permanent_inventory_item!' do
          expect(variant).not_to receive(:create_default_non_permanent_inventory_item!)
          stock_item
        end
      end

      context 'with non-permanent stock product type' do
        let(:product_type) { 'ecommerce' } # Non-permanent stock

        context 'when no default inventory item exists' do
          before do
            allow(variant).to receive(:default_inventory_item_exist?).and_return(false)
          end

          it 'creates a default non-permanent inventory item' do
            expect(variant).to receive(:create_default_non_permanent_inventory_item!).once
            stock_item

            expect(variant.inventory_items.count).to eq(1)
          end
        end

        context 'when default inventory item exists' do
          before do
            allow(variant).to receive(:default_inventory_item_exist?).and_return(true)
          end

          it 'does not create a new inventory item' do
            expect(variant).not_to receive(:create_default_non_permanent_inventory_item!)
            stock_item
          end
        end
      end
    end
  end

  describe '#callback, after_destroy' do
    it 'calls adjust_inventory_items_async' do
      expect(stock_item).to receive(:adjust_inventory_items_async)
      stock_item.destroy
    end
  end

  describe '#adjust_inventory_items_async' do
    it 'enqueues InventoryItemsAdjusterJob with variant id and negative count_on_hand' do
      expect(SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob)
        .to receive(:perform_later).with(variant_id: variant.id, quantity: -stock_item.count_on_hand)
      stock_item.send(:adjust_inventory_items_async)
    end
  end
end
