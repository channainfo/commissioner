require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemDecorator, type: :model do
  let(:line_item) { create(:line_item) }
  let(:inventory_checker) { instance_double(SpreeCmCommissioner::RedisStock::InventoryChecker) }

  describe '#sufficient_stock?' do
    before do
      allow(SpreeCmCommissioner::RedisStock::InventoryChecker).to receive(:new).with([line_item]).and_return(inventory_checker)
    end

    context 'when stock is sufficient' do
      it 'returns true when InventoryChecker confirms stock availability' do
        expect(inventory_checker).to receive(:can_supply_all?).and_return(true)
        expect(line_item.sufficient_stock?).to eq(true)
      end
    end

    context 'when stock is insufficient' do
      it 'returns false when InventoryChecker indicates insufficient stock' do
        expect(inventory_checker).to receive(:can_supply_all?).and_return(false)
        expect(line_item.sufficient_stock?).to eq(false)
      end
    end
  end
end
