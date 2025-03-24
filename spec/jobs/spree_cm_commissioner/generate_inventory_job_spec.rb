require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe GenerateInventoryJob, type: :job do
    describe '#perform' do
      let(:event_variant) { create(:variant, product: create(:product, product_type: 'event')) }
      let(:bus_variant) { create(:variant, product: create(:product, product_type: 'bus')) }
      let(:accommodation_variant) { create(:variant, product: create(:product, product_type: 'accommodation')) }

      before do
        allow(Spree::Variant).to receive(:find_each).and_yield(event_variant)
          .and_yield(bus_variant)
          .and_yield(accommodation_variant)
      end

      it 'processes all variants and calls appropriate inventory creation methods' do
        expect(subject).to receive(:create_event_inventory).with(event_variant)
        expect(subject).to receive(:create_bus_inventory).with(bus_variant)
        expect(subject).to receive(:create_accommodation_inventory).with(accommodation_variant)

        subject.perform
      end
    end

    describe '#create_event_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'event')) }

      it 'creates a single inventory unit with no date' do
        expect(subject).to receive(:create_inventory_unit).with(variant, nil)
        subject.send(:create_event_inventory, variant)
      end
    end

    describe '#create_bus_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'bus')) }
      let(:start_date) { Date.tomorrow }
      let(:end_date) { Date.today + 90 }

      it 'creates inventory units for 90 days starting tomorrow' do
        expect(subject).to receive(:create_inventory_unit).exactly(90).times
        subject.send(:create_bus_inventory, variant)
      end

      it 'creates inventory units for each date in range' do
        (start_date..end_date).each do |date|
          expect(subject).to receive(:create_inventory_unit).with(variant, date)
        end
        subject.send(:create_bus_inventory, variant)
      end
    end

    describe '#create_accommodation_inventory' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'accommodation')) }
      let(:start_date) { Date.tomorrow }
      let(:end_date) { Date.today + 365 }

      it 'creates inventory units for 365 days starting tomorrow' do
        expect(subject).to receive(:create_inventory_unit).exactly(365).times
        subject.send(:create_accommodation_inventory, variant)
      end

      it 'creates inventory units for each date in range' do
        (start_date..end_date).each do |date|
          expect(subject).to receive(:create_inventory_unit).with(variant, date)
        end
        subject.send(:create_accommodation_inventory, variant)
      end
    end

    describe '#create_inventory_unit' do
      let(:variant) { create(:variant, product: create(:product, product_type: 'event')) }
      let(:inventory_date) { Date.today }
      let(:stock) { { quantity_available: 10, max_capacity: 0 } }

      before do
        allow(variant).to receive(:inventory_unit_stock).and_return(stock)
      end

      context 'when inventory unit does not exist' do
        before do
          allow(variant.inventory_units).to receive(:exists?)
            .with(inventory_date: inventory_date)
            .and_return(false)
        end

        it 'creates a new inventory unit with correct attributes' do
          expect(InventoryUnit).to receive(:create!).with(
            variant_id: variant.id,
            inventory_date: inventory_date,
            quantity_available: stock[:quantity_available],
            max_capacity: stock[:max_capacity],
            service_type: variant.service_type
          )

          subject.send(:create_inventory_unit, variant, inventory_date)
        end
      end

      context 'when inventory unit already exists' do
        before do
          allow(variant.inventory_units).to receive(:exists?)
            .with(inventory_date: inventory_date)
            .and_return(true)
        end

        it 'does not create a new inventory unit' do
          expect(InventoryUnit).not_to receive(:create!)
          subject.send(:create_inventory_unit, variant, inventory_date)
        end
      end
    end
  end
end
