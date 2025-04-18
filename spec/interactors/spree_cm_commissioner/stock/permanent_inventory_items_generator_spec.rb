require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator, type: :interactor do
  describe '.call' do
    let(:stock_location) { create(:stock_location, active: true) }
    let(:product) { create(:product, product_type: :accommodation)}
    let(:variant) { create(:variant, is_master: false, product: product) }

    before do
      create(:stock_item, variant: variant, stock_location: stock_location, count_on_hand: 5)
    end

    it 'creates inventory items for the correct date range' do
      expected_days = variant.pre_inventory_days

      expect(expected_days).to eq 365
      expect { described_class.call(variant_ids: [variant.id]) }.to change { variant.inventory_items.count }.by(365)
    end

    it 'does not create duplicate inventory items' do
      expected_days = variant.pre_inventory_days

      create(:cm_inventory_item, variant: variant, inventory_date: Date.tomorrow, product_type: variant.product_type)
      create(:cm_inventory_item, variant: variant, inventory_date: Date.tomorrow + 1, product_type: variant.product_type)
      create(:cm_inventory_item, variant: variant, inventory_date: Date.tomorrow + 2, product_type: variant.product_type)

      expect(expected_days).to eq 365
      expect { described_class.call(variant_ids: [variant.id]) }.to change { variant.inventory_items.count }.by(362)
    end
  end

  describe '#total_on_hand_for' do
    let(:stock_location) { create(:stock_location, active: true) }
    let(:product) { create(:product, product_type: :accommodation)}

    let!(:variant1) { create(:variant, is_master: false, product: product) }
    let!(:variant2) { create(:variant, is_master: false, product: product) }

    let(:stock_item1) { variant1.stock_items.first }
    let(:stock_item2) { variant2.stock_items.first }

    it '' do
      stock_item1.update(count_on_hand: 5)
      stock_item2.update(count_on_hand: 5)

      result = described_class.new.send(:total_on_hand_for, [variant1, variant2])
      expect(result).to eq({ stock_item1.id => 5, stock_item2.id => 5 })
    end
  end
end
