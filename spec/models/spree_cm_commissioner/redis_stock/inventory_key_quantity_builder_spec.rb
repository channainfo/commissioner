require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder do
  describe '#initialize' do
    let(:line_items) { create_list(:line_item, 2) }

    it 'initializes with line_items and includes variant and inventory_items' do
      builder = described_class.new(line_items)
      expect(builder.line_items).to eq(line_items)
      expect(builder.line_items).to all(be_a(Spree::LineItem))
    end
  end

  describe '#call' do
    let(:variant) { create(:variant) }
    let(:inventory_item1) { create(:cm_inventory_item, variant: variant, id: 1, inventory_date: Date.today + 1 ) }
    let(:inventory_item2) { create(:cm_inventory_item, variant: variant, id: 2, inventory_date: Date.today + 2 ) }
    let(:line_item) do
      create(:line_item, variant: variant, quantity: 3, from_date: Date.today, to_date: Date.today + 1)
    end

    before do
      # Ensure inventory items are associated with the variant
      variant.inventory_items << [inventory_item1, inventory_item2]
    end

    context 'when line_item is not permanent stock' do
      before do
        allow(line_item).to receive(:permanent_stock?).and_return(false)
      end

      it 'returns inventory key-quantity mappings for all inventory items' do
        builder = described_class.new([line_item])
        result = builder.call

        expect(result).to match_array([
          {
            inventory_key: "inventory:1",
            quantity: 3,
            inventory_item_id: 1
          },
          {
            inventory_key: 'inventory:2',
            quantity: 3,
            inventory_item_id: 2
          }
        ])
      end
    end

    context 'when line_item is permanent stock' do
      let(:date_range) { Date.today..(Date.today + 1) }

      before do
        allow(line_item).to receive(:permanent_stock?).and_return(true)
        allow(line_item).to receive(:date_range).and_return(date_range)
      end

      it 'filters inventory items by date_range' do
        builder = described_class.new([line_item])
        result = builder.call

        expect(result).to match_array([
          {
            inventory_key: 'inventory:1',
            quantity: 3,
            inventory_item_id: 1
          }
        ])
      end
    end

    context 'when there are multiple line items' do
      let(:variant2) { create(:variant) }
      let(:inventory_item3) { create(:cm_inventory_item, variant: variant2, id: 3) }
      let(:line_item2) { create(:line_item, variant: variant2, quantity: 2) }

      before do
        variant2.inventory_items << inventory_item3
        allow(line_item).to receive(:permanent_stock?).and_return(false)
        allow(line_item2).to receive(:permanent_stock?).and_return(false)
      end

      it 'processes all line items and flattens the result' do
        builder = described_class.new([line_item, line_item2])
        result = builder.call

        expect(result).to match_array([
          {
            inventory_key: 'inventory:1',
            quantity: 3,
            inventory_item_id: 1
          },
          {
            inventory_key: 'inventory:2',
            quantity: 3,
            inventory_item_id: 2
          },
          {
            inventory_key: 'inventory:3',
            quantity: 2,
            inventory_item_id: 3
          }
        ])
      end
    end

    context 'when line_items is empty' do
      it 'returns an empty array' do
        builder = described_class.new([])
        expect(builder.call).to eq([])
      end
    end
  end

  describe '#inventory_items_for' do
    let(:variant) { create(:variant) }
    let(:line_item) { create(:line_item, variant: variant) }
    let(:inventory_item1) { create(:cm_inventory_item, variant: variant, inventory_date: Date.today + 1) }
    let(:inventory_item2) { create(:cm_inventory_item, variant: variant, inventory_date: Date.today + 2) }
    let(:inventory_items) { [inventory_item1, inventory_item2] }

    before do
      variant.inventory_items << inventory_items
    end

    context 'when line_item is not permanent stock' do
      before do
        allow(line_item).to receive(:permanent_stock?).and_return(false)
      end

      it 'returns all inventory items for the variant' do
        builder = described_class.new([line_item])
        result = builder.send(:inventory_items_for, line_item)
        expect(result).to eq(inventory_items)
      end
    end

    context 'when line_item is permanent stock' do
      let(:date_range) { Date.today..(Date.today + 1) }

      before do
        allow(line_item).to receive(:permanent_stock?).and_return(true)
        allow(line_item).to receive(:date_range).and_return(date_range)
      end

      it 'filters inventory items by date_range' do
        filtered_items = [inventory_items.first]
        expect(line_item.variant.inventory_items).to receive(:where).with(inventory_date: date_range).and_return(filtered_items)

        builder = described_class.new([line_item])
        result = builder.send(:inventory_items_for, line_item)
        expect(result).to eq(filtered_items)
      end
    end
  end
end
