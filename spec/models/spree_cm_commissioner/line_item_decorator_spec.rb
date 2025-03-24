require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemDecorator do
  let(:product) { create(:product, product_type: 'accommodation') }
  let(:variant) { product.master }
  let(:line_item) { create(:line_item, variant: variant, quantity: 2, from_date: Date.today, to_date: Date.today + 2.days) }

  describe '#inventory_params' do
    let(:inventory_items) do
      [
        create(:cm_inventory_item, variant: variant, inventory_date: Date.today),
        create(:cm_inventory_item, variant: variant, inventory_date: Date.today + 1.day)
      ]
    end

    before do
      allow(line_item).to receive(:inventory_items).and_return(inventory_items)
    end

    it 'returns an array of inventory params based on inventory items' do
      result = line_item.inventory_params
      expect(result).to eq([
        { inventory_key: "inventory:#{inventory_items[0].id}", quantity: 2 },
        { inventory_key: "inventory:#{inventory_items[1].id}", quantity: 2 }
      ])
    end

    context 'when there are no inventory items' do
      before do
        allow(line_item).to receive(:inventory_items).and_return([])
      end

      it 'returns an empty array' do
        expect(line_item.inventory_params).to eq([])
      end
    end
  end

  describe '#inventory_items' do
    let(:inventory_date_range) { (Date.today..Date.today + 1.day) }
    let(:inventory_items) do
      [
        create(:cm_inventory_item, variant: variant, inventory_date: Date.today),
        create(:cm_inventory_item, variant: variant, inventory_date: Date.today + 1.day),
        create(:cm_inventory_item, variant: variant, inventory_date: Date.today + 3.days) # Outside range
      ]
    end

    before do
      allow(variant).to receive(:inventory_items).and_return(inventory_items)
    end

    context 'when product_type is not accommodation or bus' do
      before do
        allow(product).to receive(:product_type).and_return('other')
      end

      it 'returns all inventory items without filtering' do
        result = line_item.inventory_items
        expect(result).to eq(inventory_items)
        expect(result.size).to eq(3)
      end
    end

    context 'when product_type is accommodation' do
      before do
        allow(product).to receive(:product_type).and_return(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION)
      end

      it 'filters inventory items within the date range (from_date to to_date - 1)' do
        result = line_item.inventory_items
        expect(result).to eq([inventory_items[0], inventory_items[1]]) # Only items within Date.today to Date.today + 1
      end

      context 'when from_date or to_date is nil' do
        let(:line_item) { create(:line_item, quantity: 2, from_date: nil, to_date: nil) }

        it 'returns empty array if date range cannot be determined' do
          result = line_item.inventory_items
          expect(result).to eq([])
        end
      end
    end

    context 'when product_type is bus' do
      before do
        allow(product).to receive(:product_type).and_return(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS)
      end

      it 'filters inventory items matching from_date exactly' do
        result = line_item.inventory_items
        expect(result).to eq([inventory_items[0]]) # Only item on Date.today
      end

      context 'when from_date is nil' do
        let(:line_item) { create(:line_item, quantity: 2, from_date: nil, to_date: Date.today + 2.days) }

        it 'returns empty array if from_date is nil' do
          result = line_item.inventory_items
          expect(result).to eq([])
        end
      end
    end
  end
end
