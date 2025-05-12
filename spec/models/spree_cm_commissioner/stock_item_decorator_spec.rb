require 'spec_helper'

RSpec.describe SpreeCmCommissioner::StockItemDecorator, type: :model do
  let(:stock_location) { create(:stock_location) }
  let(:product) { create(:cm_product, product_type: 'ecommerce') }
  let(:variant) { create(:cm_variant, product: product, is_master: false) }
  let(:stock_item) { create(:stock_item, variant: variant, stock_location: stock_location, count_on_hand: 0) }

  describe '#create_inventory_items' do
    context 'when creating a new stock item' do
      it 'enqueues InventoryItemsGeneratorJob with variant id' do
        expect(SpreeCmCommissioner::Stock::InventoryItemsGeneratorJob)
          .to receive(:perform_later).with(variant_id: variant.id)
        stock_item
      end

      it 'does not call create_default_non_permanent_inventory_item!' do
        expect(variant).not_to receive(:create_default_non_permanent_inventory_item!)
        stock_item
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
