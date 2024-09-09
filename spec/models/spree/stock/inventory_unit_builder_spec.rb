require 'spec_helper'

RSpec.describe Spree::Stock::InventoryUnitBuilder do
  describe '#units' do
    let(:line_item_a) { create(:line_item) }
    let(:line_item_b) { create(:line_item) }
    let(:order) { create(:order, line_items: [line_item_a, line_item_b]) }

    it 'only build unit that required delivery' do
      allow(line_item_a.variant).to receive(:delivery_required?).and_return true
      allow(line_item_b.variant).to receive(:delivery_required?).and_return false

      units = described_class.new(order).units

      expect(units.size).to eq 1
      expect(units[0].line_item_id).to eq line_item_a.id
    end
  end
end
