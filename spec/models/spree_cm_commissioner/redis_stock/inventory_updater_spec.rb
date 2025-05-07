require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::InventoryUpdater do
  describe '#unstock!' do
    let(:line_item1) { Spree::LineItem.new(id: 91, variant_id: 1, quantity: 3) }
    subject { described_class.new([line_item1.id]) }

    context 'when unstock success' do
      it 'extract_inventory_data, unstock from redis & schedule_sync_inventory to db' do
        expect(subject).to receive(:extract_inventory_data).and_return([['inventory:112', 'inventory:113'], [3, 3], [112,113]])
        expect(subject).to receive(:unstock).and_return(true)
        expect(subject).to receive(:schedule_sync_inventory).with([{:inventory_id => 112, :quantity => -3}, {:inventory_id => 113, :quantity => -3}])

        subject.unstock!
      end
    end

    context 'when failed to unstock' do
      it 'extract_inventory_data, unstock from redis & throw the error' do
        expect(subject).to receive(:extract_inventory_data).and_return([['inventory:112', 'inventory:113'], [3, 3], [112,113]])
        expect(subject).to receive(:unstock).and_return(false)

        expect {
          subject.unstock!
        }.to raise_error(described_class::UnableToUnstock, Spree.t(:insufficient_stock_lines_present))
      end
    end
  end

  describe '#restock!' do
    let(:line_item1) { Spree::LineItem.new(id: 91, variant_id: 1, quantity: 3) }
    subject { described_class.new([line_item1.id]) }

    context 'when restock success' do
      it 'extract_inventory_data, restock from redis & schedule_sync_inventory to db' do
        expect(subject).to receive(:extract_inventory_data).and_return([['inventory:112', 'inventory:113'], [3, 3], [112,113]])
        expect(subject).to receive(:restock).and_return(true)
        expect(subject).to receive(:schedule_sync_inventory).with([{:inventory_id => 112, :quantity => 3}, {:inventory_id => 113, :quantity => 3}])

        subject.restock!
      end
    end

    context 'when failed to restock' do
      it 'extract_inventory_data, restock from redis & throw the error' do
        expect(subject).to receive(:extract_inventory_data).and_return([['inventory:112', 'inventory:113'], [3, 3], [112,113]])
        expect(subject).to receive(:restock).and_return(false)

        expect {
          subject.restock!
        }.to raise_error(described_class::UnableToRestock)
      end
    end
  end

  describe '#extract_inventory_data' do
    let(:line_item1) { Spree::LineItem.new(id: 91, variant_id: 1, quantity: 3) }
    let(:line_item2) { Spree::LineItem.new(id: 92, variant_id: 2, quantity: 3) }

    let(:line_item_ids) { [line_item1.id, line_item2.id] }

    subject { described_class.new(line_item_ids) }

    # no db needed, it do entirely in class object level.
    it 'construct inventory_data from cached_inventory_items & quantity from line_items' do
      expect(subject).to receive(:cached_inventory_items).and_return([
        SpreeCmCommissioner::CachedInventoryItem.new(
          inventory_key: 'inventory:112',
          active: true,
          quantity_available: 3,
          inventory_item_id: 112,
          variant_id: 1,
        ),
        SpreeCmCommissioner::CachedInventoryItem.new(
          inventory_key: 'inventory:113',
          active: true,
          quantity_available: 3,
          inventory_item_id: 113,
          variant_id: 2,
        ),
      ])

      expect(subject).to receive(:line_items).twice.and_return([
        line_item1,
        line_item2
      ])

      expect(subject.send(:extract_inventory_data)).to eq [["inventory:112", "inventory:113"], [3, 3], [112, 113]]
    end
  end


  describe '#cached_inventory_items' do
    let(:line_item1) { Spree::LineItem.new(id: 91, variant_id: 1, quantity: 3) }
    let(:line_item2) { Spree::LineItem.new(id: 92, variant_id: 2, quantity: 3) }

    let(:line_item_ids) { [line_item1.id, line_item2.id] }

    subject { described_class.new(line_item_ids) }

    it 'call SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder with only line item return from line_items method' do
      expect(subject).to receive(:line_items).once.and_return([line_item1])

      # even there are 2 line items passed, if line_items return 1, it will recieve one
      expect(SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder).to receive(:new).with(line_item_ids: [line_item1.id]).and_call_original
      expect_any_instance_of(SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder).to receive(:call).and_return({})

      subject.send(:cached_inventory_items)
    end
  end

  # we want to unstock variant that aren't meet these condition
  # so line item method should only return line items that ready.
  describe '#line_items' do
    context 'when line items is not_track_inventory, backorderable, or need_confirmation' do
      let(:not_available_variant) { double(:variant, id: 33, available?: false) }
      let(:not_track_inventory_variant) { double(:variant, id: 33, available?: true, should_track_inventory?: false) }
      let(:backorderable_variant) { double(:variant, id: 34, available?: true, should_track_inventory?: true, backorderable?: true) }
      let(:need_confirmation_variant) { double(:variant, id: 35, available?: true, should_track_inventory?: true, backorderable?: false, need_confirmation?: true) }
      let(:eligible_variant) { double(:variant, id: 36, available?: true, should_track_inventory?: true, backorderable?: false, need_confirmation?: false) }

      let(:not_available_line_item) { double(:line_item, id: 93, quantity: 3, variant: not_available_variant) }
      let(:not_track_inventory_line_item) { double(:line_item, id: 93, quantity: 3, variant: not_track_inventory_variant) }
      let(:backorderable_line_item) { double(:line_item, id: 91, quantity: 3, variant: backorderable_variant) }
      let(:need_confirmation_line_item) { double(:line_item, id: 92, quantity: 3, variant: need_confirmation_variant) }
      let(:eligible_line_item) { double(:line_item, id: 94, quantity: 3, variant: eligible_variant) }

      let(:line_items) { [ not_available_line_item, not_track_inventory_line_item, backorderable_line_item, need_confirmation_line_item, eligible_line_item ] }
      let(:line_item_ids) { line_items.map(&:id) }

      subject { described_class.new(line_item_ids) }

      it 'filtered & return only 1 line item which track inventory, not backorderable & not need confirmation' do
        expect(Spree::LineItem).to receive(:where).with(id: line_item_ids).and_return(line_items)
        expect(line_items).to receive(:includes).with(variant: :stock_items).and_return(line_items)

        expect(subject.send(:line_items)).to eq([eligible_line_item])
      end
    end
  end

  context 'unstock/restock with real redis' do
    subject { described_class.new([]) }

    before do
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.set('inventory:1', 5)
        redis.set('inventory:2', 5)
      end
    end

    # Clean up Redis keys
    after do
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.del('inventory:1', 'inventory:2')
      end
    end

    # unstock with real redis
    describe '#unstock' do
      context 'when final stock >= 0' do
        it 'subtract the quantity from redis & return TRUE' do
          keys = ['inventory:1', 'inventory:2']
          quantities = [3, 5]

          success = subject.send(:unstock, keys, quantities)
          result = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(keys) }

          expect(result).to eq(["2", "0"])
          expect(success).to be true
        end
      end

      context 'when final stock < 0' do
        it 'keep original redis quantity & return FALSE' do
          keys = ['inventory:1', 'inventory:2']
          quantities = [3, 6]

          success = subject.send(:unstock, keys, quantities)
          result = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(keys) }

          expect(result).to eq(["5", "5"])
          expect(success).to be false
        end
      end
    end

    # restock with real redis
    describe '#restock' do
      it 'add the quantity to redis & return true' do
        keys = ['inventory:1', 'inventory:2']
        quantities = [3, 6]

        success = subject.send(:restock, keys, quantities)
        result = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(keys) }

        expect(result).to eq(["8", "11"])
        expect(success).to be true
      end
    end
  end
end
