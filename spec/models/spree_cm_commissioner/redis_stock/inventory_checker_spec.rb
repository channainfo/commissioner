require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryChecker do
  let(:line_item_ids) { [1, 2] }
  let(:inventory_builder) { instance_double(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder) }
  let(:inventory_items) do
    [
      { inventory_key: "inventory:1", purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1 },
      { inventory_key: "inventory:2", purchase_quantity: 1, quantity_available: 3, inventory_item_id: 2 }
    ]
  end

  subject { described_class.new(line_item_ids) }

  before do
    allow(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder).to receive(:new).with(line_item_ids).and_return(inventory_builder)
    allow(inventory_builder).to receive(:call).and_return(inventory_items)
  end

  describe '#initialize' do
    it 'sets line_item_ids' do
      expect(subject.instance_variable_get(:@line_item_ids)).to eq(line_item_ids)
    end
  end

  describe '#can_supply_all?' do
    context 'when inventory items have sufficient quantity' do
      it 'returns true' do
        expect(subject.can_supply_all?).to be true
      end
    end

    context 'when at least one inventory item has insufficient quantity' do
      let(:inventory_items) do
        [
          { inventory_key: "inventory:1", purchase_quantity: 2, quantity_available: 5, inventory_item_id: 1 },
          { inventory_key: "inventory:2", purchase_quantity: 3, quantity_available: 2, inventory_item_id: 2 }
        ]
      end

      it 'returns false' do
        expect(subject.can_supply_all?).to be false
      end
    end

    context 'when inventory items are empty' do
      let(:inventory_items) { [] }

      it 'returns false' do
        expect(subject.can_supply_all?).to be false
      end
    end

    context 'when line_item_ids is empty' do
      let(:line_item_ids) { [] }

      it 'returns false' do
        expect(subject.can_supply_all?).to be false
      end
    end

    context 'when line_item_ids is nil' do
      let(:line_item_ids) { nil }

      it 'returns false' do
        expect(subject.can_supply_all?).to be false
      end
    end
  end

  describe '#inventory_items' do
    it 'calls InventoryKeyQuantityBuilder with line_item_ids' do
      expect(SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder).to receive(:new).with(line_item_ids).and_return(inventory_builder)
      expect(inventory_builder).to receive(:call).and_return(inventory_items)
      subject.send(:inventory_items)
    end

    it 'returns the result of InventoryKeyQuantityBuilder#call' do
      expect(subject.send(:inventory_items)).to eq(inventory_items)
    end

    it 'memoizes the result of InventoryKeyQuantityBuilder#call' do
      expect(inventory_builder).to receive(:call).once.and_return(inventory_items)
      subject.send(:inventory_items)
      subject.send(:inventory_items) # Second call should use memoized result
      expect(subject.instance_variable_get(:@inventory_items)).to eq(inventory_items)
    end
  end
end
