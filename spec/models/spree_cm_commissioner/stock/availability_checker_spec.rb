require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::AvailabilityChecker do
  describe '#can_supply?' do
    context 'basic conditions' do
      context 'when variant.available? is false' do
        it 'return can_supply? false' do
          discontinued_variant = create(:cm_variant, discontinue_on: Time.current)
          inactive_variant = create(:cm_variant, product: create(:cm_product, status: :archived))

          subject_1 = described_class.new(discontinued_variant)
          subject_2 = described_class.new(inactive_variant)

          expect(discontinued_variant.available?).to be false
          expect(inactive_variant.available?).to be false

          expect(subject_1.can_supply?).to be false
          expect(subject_2.can_supply?).to be false
        end
      end

      context 'when variant.should_track_inventory? is false' do
        let(:variant) { create(:cm_variant, track_inventory: false) }
        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          expect(variant.should_track_inventory?).to be false
          expect(subject.can_supply?).to be true
        end
      end

      context 'when variant.backorderable? is true' do
        let(:variant) { create(:cm_variant) }

        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          variant.stock_items.update_all(backorderable: true)

          expect(variant.backorderable?).to be true
          expect(subject.can_supply?).to be true
        end
      end

      context 'when variant.need_confirmation? is true' do
        let(:product) { create(:cm_product, need_confirmation: true) }
        let(:variant) { create(:cm_variant, product: product) }

        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          expect(variant.need_confirmation?).to be true
          expect(subject.can_supply?).to be true
        end
      end

      context 'when cached_inventory_items is empty' do
        let(:product) { create(:cm_product, product_type: :accommodation) }
        let(:variant) { create(:cm_variant, product: product) }

        subject { described_class.new(variant) }

        it 'return can_supply? false' do
          expect(variant.available?).to be true
          expect(variant.should_track_inventory?).to be true
          expect(variant.backorderable?).to be false
          expect(variant.need_confirmation?).to be false

          expect(subject).to receive(:cached_inventory_items).and_return([])
          expect(subject.can_supply?).to be false
        end
      end
    end

    context 'check with redis after passed basic conditions above' do
      let(:variant) { create(:cm_variant, track_inventory: true, discontinue_on: nil) }
      subject { described_class.new(variant) }

      let(:cached_inventory_klass) { SpreeCmCommissioner::CachedInventoryItem }
      let(:quantity_available) { 5 }
      let(:cached_inventory_items) do
        [ cached_inventory_klass.new(inventory_key: "inventory:1", active: true, quantity_available: quantity_available, inventory_item_id: 1, variant_id: variant.id) ]
      end

      before do
        variant.stock_items.update_all(backorderable: false)
        expect(variant.available?).to be true
        expect(variant.should_track_inventory?).to be true
        expect(variant.backorderable?).to be false
        expect(variant.need_confirmation?).to be false
      end

      it 'call :cached_inventory_items & check avalability with it' do
        allow(subject).to receive(:cached_inventory_items).and_return(cached_inventory_items)

        expect(subject.can_supply?(4)).to be true
        expect(subject.can_supply?(5)).to be true
        expect(subject.can_supply?(6)).to be false
      end
    end
  end

  describe '#cached_inventory_items' do
    context 'when variant has permanent_stock (accomodation, transit, ...)' do
      let(:product) { create(:cm_product, product_type: :accommodation) }
      let(:variant) { create(:cm_variant, product: product, total_inventory: 10, pregenerate_inventory_items: true, pre_inventory_days: 2) }

      context 'when inventory_items are exist for all dates' do
        let(:options) { { from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 1 } }
        subject { described_class.new(variant, options) }

        it 'fetch inventories key/quantity from VariantCachedInventoryItemsBuilder with :variant_id & date options' do
          expect_any_instance_of(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:call).once.and_call_original
          expect(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:new).with(
            variant_id: variant.id,
            dates: options[:from_date].to_date..options[:to_date].to_date,
          ).once.and_call_original

          expect(subject.cached_inventory_items.count).to eq 2

          expect(subject.cached_inventory_items[0].inventory_item_id).to eq variant.inventory_items[0].id
          expect(subject.cached_inventory_items[0].active).to eq true

          expect(subject.cached_inventory_items[1].inventory_item_id).to eq variant.inventory_items[1].id
          expect(subject.cached_inventory_items[1].active).to eq true
        end
      end

      context 'when inventory_items are NOT exist for some dates' do
        let(:options) { { from_date: Time.zone.today, to_date: Time.zone.tomorrow + 1.day } }
        subject { described_class.new(variant, options) }

        it 'return empty' do
          expect(subject.cached_inventory_items).to eq([])
        end
      end
    end

    context 'when variant has normal stock (ecommerce, ...)' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product) }

      subject { described_class.new(variant) }

      it 'fetch inventories key/quantity from VariantCachedInventoryItemsBuilder with just :variant_id' do
        expect(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:new).with(variant_id: variant.id).once.and_call_original
        expect_any_instance_of(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:call).once

        subject.cached_inventory_items
      end
    end
  end
end
