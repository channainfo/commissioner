require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe InventoryItemGenerator, type: :interactor do
    describe '#call' do
      let(:variant_event) { create(:product, product_type: 'event').master }
      let(:variant_bus) { create(:product, product_type: 'bus').master }
      let(:variant_accommodation) { create(:product, product_type: 'accommodation').master }
      let(:stock) { { quantity_available: 10, max_capacity: 20 } }

      before do
        allow(Spree::Variant).to receive(:find_each).and_yield(variant_event)
                                        .and_yield(variant_bus)
                                        .and_yield(variant_accommodation)
      end

      it 'processes all variants and calls appropriate inventory creation methods' do
        expect(subject).to receive(:create_event_inventory).with(variant_event)
        expect(subject).to receive(:create_bus_inventory).with(variant_bus)
        expect(subject).to receive(:create_accommodation_inventory).with(variant_accommodation)

        subject.call
      end
    end

    describe '#create_event_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'event')) }

      it 'creates a single inventory item with no date' do
        expect(subject).to receive(:create_inventory_item).with(variant, nil)
        subject.send(:create_event_inventory, variant)
      end
    end

    describe '#create_bus_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'bus')) }
      let(:start_date) { Date.tomorrow }
      let(:end_date) { Date.today + 90 }

      it 'creates inventory items for 90 days starting tomorrow' do
        expect(subject).to receive(:create_inventory_item).exactly(90).times
        subject.send(:create_bus_inventory, variant)
      end

      it 'creates inventory items for each date in range' do
        (start_date..end_date).each do |date|
          expect(subject).to receive(:create_inventory_item).with(variant, date)
        end
        subject.send(:create_bus_inventory, variant)
      end
    end

    describe '#create_accommodation_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'accommodation')) }
      let(:start_date) { Date.tomorrow }
      let(:end_date) { Date.today + 365 }

      it 'creates inventory items for 365 days starting tomorrow' do
        expect(subject).to receive(:create_inventory_item).exactly(365).times
        subject.send(:create_accommodation_inventory, variant)
      end

      it 'creates inventory items for each date in range' do
        (start_date..end_date).each do |date|
          expect(subject).to receive(:create_inventory_item).with(variant, date)
        end
        subject.send(:create_accommodation_inventory, variant)
      end
    end

    describe '#create_inventory_item' do
      let(:variant) { create(:product, product_type: 'event').master }
      let(:inventory_date) { Date.today }
      let(:stock) { { quantity_available: 10, max_capacity: 0 } }
      let(:inventory_item) { instance_double(InventoryItem, id: 1, quantity_available: 10, inventory_date: inventory_date) }

      before do
        allow(variant).to receive(:inventory_item_stock).and_return(stock)
      end

      context 'when inventory item does not exist' do
        before do
          allow(variant.inventory_items).to receive(:exists?)
            .with(inventory_date: inventory_date)
            .and_return(false)
        end

        it 'creates a new inventory item with correct attributes' do
          allow(subject).to receive(:cache_inventory_in_redis)

          expect(InventoryItem).to receive(:create!).with(
            variant_id: variant.id,
            inventory_date: inventory_date,
            quantity_available: stock[:quantity_available],
            max_capacity: stock[:max_capacity],
            product_type: variant.product_type
          )

          subject.send(:create_inventory_item, variant, inventory_date)
        end

        it 'caches the inventory in Redis after creation' do
          allow(InventoryItem).to receive(:create!).and_return(inventory_item)

          expect(subject).to receive(:cache_inventory_in_redis).with(inventory_item)
          subject.send(:create_inventory_item, variant, inventory_date)
        end
      end

      context 'when inventory item already exists' do
        before do
          allow(variant.inventory_items).to receive(:exists?)
            .with(inventory_date: inventory_date)
            .and_return(true)
        end

        it 'does not create a new inventory item' do
          expect(InventoryItem).not_to receive(:create!)
          subject.send(:create_inventory_item, variant, inventory_date)
        end
      end
    end

    describe '#cache_inventory_in_redis' do
      let(:inventory_item) { instance_double(InventoryItem, id: 1, quantity_available: 15, inventory_date: inventory_date) }
      let(:redis) { double('Redis') }
      let(:redis_pool) { double('redis_pool') }
      let(:subject) { described_class.new(Interactor::Context.new) }
      let(:current_time) { Time.parse('2025-03-31 12:00:00 UTC') }

      before do
        allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
        allow(redis_pool).to receive(:with).and_yield(redis)
        allow(Time).to receive(:now).and_return(current_time)
      end

      context 'with a specific inventory date' do
        let(:inventory_date) { Date.parse('2025-04-15') }

        it 'sets the quantity_available in Redis with correct key and calculated expiration' do
          expected_expiration = (Time.parse('2025-04-15 23:59:59 UTC').to_i - current_time.to_i)

          expect(redis).to receive(:set).with(
            'inventory:1',
            15,
            ex: expected_expiration
          )

          subject.send(:cache_inventory_in_redis, inventory_item)
        end
      end

      context 'with nil inventory date (event inventory)' do
        let(:inventory_date) { nil }

        it 'sets the quantity_available with a one-year expiration' do
          expect(redis).to receive(:set).with(
            'inventory:1',
            15,
            ex: 31_536_000
          )

          subject.send(:cache_inventory_in_redis, inventory_item)
        end
      end

      context 'when Redis operation fails' do
        let(:inventory_date) { Date.tomorrow }

        before do
          allow(redis).to receive(:set).and_raise(Redis::CannotConnectError)
        end

        it 'raises the Redis error' do
          expect {
            subject.send(:cache_inventory_in_redis, inventory_item)
          }.to raise_error(Redis::CannotConnectError)
        end
      end

      context 'with different quantity_available values' do
        let(:inventory_date) { Date.tomorrow }
        let(:inventory_item) { instance_double(InventoryItem, id: 1, quantity_available: quantity, inventory_date: inventory_date) }

        [0, 100, -1].each do |test_quantity|
          context "when quantity_available is #{test_quantity}" do
            let(:quantity) { test_quantity }

            it 'caches the specific quantity value' do
              expect(redis).to receive(:set).with(
                'inventory:1',
                test_quantity,
                ex: anything
              )
              subject.send(:cache_inventory_in_redis, inventory_item)
            end
          end
        end
      end
    end
  end
end

#
