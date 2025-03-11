require 'spec_helper'

RSpec.describe SpreeCmCommissioner::BookingServices::AccommodationService do
  let(:variant) { create(:variant) }
  let(:redis) { Redis.new(url: "redis://redis:6379/12") }
  let(:check_in) { Date.parse('2025-04-01') }
  let(:check_out) { Date.parse('2025-04-03') }
  let(:service) { described_class.new(variant_id: variant.id) }

  before do
    # Mock Redis instance
    allow(Redis).to receive(:new).and_return(redis)
    allow(redis).to receive(:pipelined).and_yield(redis)
  end

  describe '#book' do
    context 'with sufficient inventory' do
      let!(:inventory_units) do
        [
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in, quantity_available: 5),
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in + 1.day, quantity_available: 5)
        ]
      end

      before do
        # Set up initial Redis values
        inventory_units.each do |unit|
          redis.set("inventory:#{unit.id}", unit.quantity_available)
        end
      end

      it 'successfully books the rooms' do
        expect(SyncInventoryJob).to receive(:perform_later)
          .with(array_including(inventory_units.map(&:id)), 2)

        result = service.book(check_in, check_out, 2)
        expect(result).to be true

        # Verify Redis counts decreased
        inventory_units.each do |unit|
          expect(redis.get("inventory:#{unit.id}").to_i).to eq(3) # 5 - 2 = 3
        end
      end

      it 'enqueues sync job with correct inventory IDs and quantity' do
        expect(SyncInventoryJob).to receive(:perform_later)
          .with(array_including(inventory_units.map(&:id)), 3)

        service.book(check_in, check_out, 3)
      end
    end

    context 'with insufficient inventory' do
      let!(:inventory_units) do
        [
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in, quantity_available: 2),
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in + 1.day, quantity_available: 1)
        ]
      end

      before do
        inventory_units.each do |unit|
          redis.set("inventory:#{unit.id}", unit.quantity_available)
        end
      end

      it 'raises error and rolls back changes when inventory is insufficient' do
        expect {
          service.book(check_in, check_out, 2)
        }.to raise_error("Not enough inventory")

        # Verify rollback occurred - quantities remain unchanged
        expect(redis.get("inventory:#{inventory_units[0].id}").to_i).to eq(2)
        expect(redis.get("inventory:#{inventory_units[1].id}").to_i).to eq(1)
      end

      it 'does not enqueue sync job' do
        expect(SyncInventoryJob).not_to receive(:perform_later)

        begin
          service.book(check_in, check_out, 2)
        rescue
          nil
        end
      end
    end

    context 'with edge cases' do
      it 'handles single-day booking' do
        inventory_unit = create(:cm_inventory_unit, variant: variant, inventory_date: check_in, quantity_available: 5)
        redis.set("inventory:#{inventory_unit.id}", 5)

        expect(SyncInventoryJob).to receive(:perform_later)
          .with([inventory_unit.id], 1)

        result = service.book(check_in, check_in + 1.day, 1)
        expect(result).to be true
        expect(redis.get("inventory:#{inventory_unit.id}").to_i).to eq(4)
      end

      it 'handles maximum available rooms' do
        inventory_units = [
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in, quantity_available: 3),
          create(:cm_inventory_unit, variant: variant, inventory_date: check_in + 1.day, quantity_available: 3)
        ]
        inventory_units.each { |unit| redis.set("inventory:#{unit.id}", 3) }

        expect(SyncInventoryJob).to receive(:perform_later)
          .with(array_including(inventory_units.map(&:id)), 3)

        result = service.book(check_in, check_out, 3)
        expect(result).to be true
        inventory_units.each do |unit|
          expect(redis.get("inventory:#{unit.id}").to_i).to eq(0)
        end
      end
    end
  end

  describe '#service_type' do
    it 'returns "accommodation"' do
      expect(service.send(:service_type)).to eq('accommodation')
    end
  end
end
