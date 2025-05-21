require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::OrderAvailabilityChecker do
  let(:product) { create(:cm_product, product_type: :ecommerce) }
  let!(:variant) { create(:cm_variant, product: product, total_inventory: 10, track_inventory: true, backorderable: false) }

  before do
    variant.create_default_non_permanent_inventory_item!
  end

  describe '#can_supply_all?' do
    let(:line_item) { create(:line_item, product: product, variant: variant, quantity: 9) }
    subject { described_class.new(line_item.order) }

    it 'return true when insufficient_stock_lines return empty' do
      expect(subject).to receive(:insufficient_stock_lines).and_return([])
      expect(subject.can_supply_all?).to eq true
    end

    it 'return false when insufficient_stock_lines return any items' do
      expect(subject).to receive(:insufficient_stock_lines).and_return([line_item])
      expect(subject.can_supply_all?).to eq false
    end
  end

  describe '#insufficient_stock_lines' do
    let(:line_item) { create(:line_item, variant: variant, quantity: 10) }
    subject { described_class.new(line_item.order) }

    it 'return empty when result from key builder is enough' do
      cached_inventory_items_group_by_line_item_id = {
        line_item.id => [ SpreeCmCommissioner::CachedInventoryItem.new(inventory_key: "inventory:1", active: true, quantity_available: 10, inventory_item_id: 1, variant_id: 2 ) ]
      }

      expect(subject).to receive(:cached_inventory_items_group_by_line_item_id).and_return(cached_inventory_items_group_by_line_item_id)
      expect(subject.insufficient_stock_lines).to eq([])
    end

    it 'return list of line item when result from key builder is not enough' do
      cached_inventory_items_group_by_line_item_id = {
        line_item.id => [ SpreeCmCommissioner::CachedInventoryItem.new(inventory_key: "inventory:1", active: true, quantity_available: 9, inventory_item_id: 1, variant_id: 2) ]
      }

      expect(subject).to receive(:cached_inventory_items_group_by_line_item_id).and_return(cached_inventory_items_group_by_line_item_id)
      expect(subject.insufficient_stock_lines.map(&:id)).to eq([line_item.id])
    end
  end

  describe '#sufficient_stock_for?' do
    let!(:line_item) { create(:line_item, variant: variant, quantity: 10) }
    subject { described_class.new(line_item.order) }

    context 'when not pass db check' do
      context 'when variant.available? is false' do
        it 'return false' do
          allow(variant).to receive(:available?).and_return(false)

          expect(subject.sufficient_stock_for?(line_item, [])).to eq false
        end
      end

      context 'when variant.should_track_inventory? is false' do
        it 'return true directly' do
          allow(variant).to receive(:available?).and_return(true)
          allow(variant).to receive(:should_track_inventory?).and_return(false)

          expect(subject.sufficient_stock_for?(line_item, [])).to eq true
        end
      end

      context 'when variant.backorderable? is true' do
        it 'return true directly' do
          allow(variant).to receive(:available?).and_return(true)
          allow(variant).to receive(:should_track_inventory?).and_return(true)
          allow(variant).to receive(:backorderable?).and_return(true)

          expect(subject.sufficient_stock_for?(line_item, [])).to eq true
        end
      end

      context 'when variant.need_confirmation? is true' do
        it 'return true directly' do
          allow(variant).to receive(:available?).and_return(true)
          allow(variant).to receive(:should_track_inventory?).and_return(true)
          allow(variant).to receive(:backorderable?).and_return(false)
          allow(variant).to receive(:need_confirmation?).and_return(true)

          expect(subject.sufficient_stock_for?(line_item, [])).to eq true
        end
      end
    end

    context 'when passed basic db check -> continue checking with redis' do
      before do
        allow(variant).to receive(:available?).and_return(true)
        allow(variant).to receive(:should_track_inventory?).and_return(true)
        allow(variant).to receive(:backorderable?).and_return(false)
        allow(variant).to receive(:need_confirmation?).and_return(false)
      end

      context 'when quantity is available & inventory item is ACTIVE' do
        it 'return true' do
          inventory_items = [ SpreeCmCommissioner::CachedInventoryItem.new(inventory_key: "inventory:1", active: true, quantity_available: 10, inventory_item_id: 1, variant_id: 2) ]
          expect(subject.sufficient_stock_for?(line_item, inventory_items)).to eq true
        end
      end

      context 'when quantity is available but inventory item is not ACTIVE' do
        it 'return false' do
          inventory_items = [ SpreeCmCommissioner::CachedInventoryItem.new(inventory_key: "inventory:1", active: false, quantity_available: 10, inventory_item_id: 1, variant_id: 2 ) ]
          expect(subject.sufficient_stock_for?(line_item, inventory_items)).to eq false
        end
      end
    end
  end
end
