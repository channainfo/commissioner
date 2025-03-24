# spec/spree_cm_commissioner/inventory_item_generator_spec.rb
require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe InventoryItemGenerator, type: :interactor do
    describe '#call' do
      let(:variant_event) { create(:variant, product: create(:product, product_type: 'event')) }
      let(:variant_bus) { create(:variant, product: create(:product, product_type: 'bus')) }
      let(:variant_accommodation) { create(:variant, product: create(:product, product_type: 'accommodation')) }
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
      let(:variant) { create(:variant, product: create(:product, product_type: 'event')) }
      let(:inventory_date) { Date.today }
      let(:stock) { { quantity_available: 10, max_capacity: 0 } }

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
          expect(InventoryItem).to receive(:create!).with(
            variant_id: variant.id,
            inventory_date: inventory_date,
            quantity_available: stock[:quantity_available],
            max_capacity: stock[:max_capacity],
            product_type: variant.product_type
          )

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
  end
end
