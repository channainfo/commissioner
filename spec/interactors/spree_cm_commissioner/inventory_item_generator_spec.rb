require 'spec_helper'

module SpreeCmCommissioner
  RSpec.describe InventoryItemGenerator, type: :interactor do
    describe '#call' do
      let(:variant1) { create(:variant) }
      let(:variant2) { create(:variant) }
      let(:context) { Interactor::Context.new(variant_ids: [variant1.id, variant2.id]) }

      before do
        allow(subject).to receive(:context).and_return(context)
        allow(subject).to receive(:variants).and_return(double(:variants))
      end

      it 'processes variants in batches of 1000' do
        expect(subject.send(:variants)).to receive(:in_batches).with(of: 1000).and_yield([variant1, variant2])
        expect(subject).to receive(:process_batch).with([variant1, variant2])
        subject.call
      end
    end

    describe '#process_batch' do
      let(:variant1) { create(:variant) }
      let(:variant2) { create(:variant) }
      let(:batch) { [variant1, variant2] }
      let(:total_on_hand) { { variant1.id => 10, variant2.id => 5 } }

      before do
        allow(subject).to receive(:calculate_total_on_hand).with(batch).and_return(total_on_hand)
      end

      context 'when variants do not require delivery' do
        before do
          allow(variant1).to receive(:delivery_required?).and_return(false)
          allow(variant2).to receive(:delivery_required?).and_return(false)
        end

        it 'processes all variants' do
          expect(subject).to receive(:generate_inventory_items).with(variant1, 10)
          expect(subject).to receive(:generate_inventory_items).with(variant2, 5)
          subject.send(:process_batch, batch)
        end
      end

      context 'when some variants require delivery' do
        before do
          allow(variant1).to receive(:delivery_required?).and_return(true)
          allow(variant2).to receive(:delivery_required?).and_return(false)
        end

        it 'skips variants that require delivery' do
          expect(subject).not_to receive(:generate_inventory_items).with(variant1, 10)
          expect(subject).to receive(:generate_inventory_items).with(variant2, 5)
          subject.send(:process_batch, batch)
        end
      end
    end

    describe '#generate_inventory_items' do
      let(:max_capacity) { 10 }
      let(:variant) { create(:variant) }

      before do
        allow(variant).to receive(:delivery_required?).and_return(false)
      end

      context 'when variant has permanent stock' do
        before { allow(variant).to receive(:permanent_stock?).and_return(true) }

        context 'with product_type transit' do
          before do
            allow(variant).to receive(:product_type).and_return('transit')
            allow(variant).to receive(:pre_inventory_days).and_return(90)
          end

          it 'creates inventory items for 90 days starting tomorrow' do
            expect(subject).to receive(:create_inventory_item).exactly(90).times do |args|
              expect(args[:variant]).to eq(variant)
              expect(args[:inventory_date]).to be_between(Date.tomorrow, Date.tomorrow + 89.days)
              expect(args[:max_capacity]).to eq(10)
            end
            subject.send(:generate_inventory_items, variant, max_capacity)
          end
        end

        context 'with product_type accommodation' do
          before do
            allow(variant).to receive(:product_type).and_return('accommodation')
            allow(variant).to receive(:pre_inventory_days).and_return(365)
          end

          it 'creates inventory items for 365 days starting tomorrow' do
            expect(subject).to receive(:create_inventory_item).exactly(365).times do |args|
              expect(args[:variant]).to eq(variant)
              expect(args[:inventory_date]).to be_between(Date.tomorrow, Date.tomorrow + 364.days)
              expect(args[:max_capacity]).to eq(10)
            end
            subject.send(:generate_inventory_items, variant, max_capacity)
          end
        end
      end

      context 'when variant does not have permanent stock' do
        before { allow(variant).to receive(:permanent_stock?).and_return(false) }

        it 'creates a single inventory item with nil inventory_date' do
          expect(subject).to receive(:create_inventory_item).with(variant: variant, inventory_date: nil, max_capacity: 10)
          subject.send(:generate_inventory_items, variant, max_capacity)
        end
      end
    end

    describe '#create_inventory_item' do
      let(:product) { create(:product, product_type: 'accommodation') }
      let(:variant) { create(:variant, product: product) }
      let(:max_capacity) { 10 }
      let(:inventory_date) { Date.tomorrow }

      context 'when inventory item does not exist' do
        before do
          allow(variant).to receive(:inventory_items).and_return(double(:inventory_items, exists?: false))
          allow(variant).to receive(:reserved_quantity).and_return(3)
          allow(variant).to receive(:product_type).and_return('accommodation')
        end

        it 'creates a new inventory item' do
          expect(InventoryItem).to receive(:create!).with(
            variant_id: variant.id,
            inventory_date: inventory_date,
            quantity_available: 7,
            max_capacity: 10,
            product_type: 'accommodation'
          )
          subject.send(:create_inventory_item, variant: variant, inventory_date: inventory_date, max_capacity: max_capacity)
        end
      end

      context 'when inventory item already exists' do
        before do
          allow(variant).to receive(:inventory_items).and_return(double(:inventory_items, exists?: true))
        end

        it 'does not create a new inventory item' do
          expect(InventoryItem).not_to receive(:create!)
          subject.send(:create_inventory_item, variant: variant, inventory_date: inventory_date, max_capacity: max_capacity)
        end
      end
    end

    describe '#calculate_total_on_hand' do
      let(:variant1) { create(:variant) }
      let(:variant2) { create(:variant) }
      let(:batch) { [variant1, variant2] }
      let(:stock_item) { double(:stock_item) }

      it 'returns total on hand for variants in batch' do
        expect(Spree::StockItem).to receive(:joins).with(:stock_location).and_return(stock_item)
        expect(stock_item).to receive(:where).with(deleted_at: nil, variant_id: [variant1.id, variant2.id]).and_return(stock_item)
        expect(stock_item).to receive(:where).with(spree_stock_locations: { active: true }).and_return(stock_item)
        expect(stock_item).to receive(:group).with(:variant_id).and_return(stock_item)
        expect(stock_item).to receive(:sum).with(:count_on_hand).and_return({ variant1.id => 10, variant2.id => 5 })
        result = subject.send(:calculate_total_on_hand, batch)
        expect(result).to eq({ variant1.id => 10, variant2.id => 5 })
      end
    end

    describe '#variants' do
      let!(:variant) { create(:variant, is_master: false) }
      let!(:order) { create(:order, state: 'complete', completed_at: Date.yesterday) }
      let!(:line_item) { create(:line_item, order: order, variant: variant, quantity: 1) }
      let(:context) { Interactor::Context.new(variant_ids: [variant.id]) }

      before do
        allow(subject).to receive(:context).and_return(context)
        allow(subject).to receive(:scope).and_return(Spree::Variant.where(id: variant.id))
      end

      it 'returns variants with reserved quantity' do
        expect(subject.send(:variants)).to include(variant)
      end
    end

    describe '#scope' do
      let(:context) { Interactor::Context.new(variant_ids: nil) }

      before do
        allow(subject).to receive(:context).and_return(context)
      end

      it 'returns active variants that are not master' do
        expect(subject.send(:scope).to_sql).to include("\"spree_variants\".\"is_master\" = FALSE")
      end

      context 'when variant_ids are present' do
        let(:context) { Interactor::Context.new(variant_ids: [1, 2]) }

        before { allow(subject).to receive(:context).and_return(context) }

        it 'filters by variant_ids' do
          expect(subject.send(:scope).to_sql).to include("\"spree_variants\".\"id\" IN (1, 2)")
        end
      end
    end
  end
end
