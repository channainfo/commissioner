require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::AvailabilityChecker do
  describe '#can_supply?' do
    context 'basic conditions' do
      context 'when variant.available? is false' do
        it 'return can_supply? false' do
          discontinued_variant = create(:variant, discontinue_on: Time.current)
          inactive_variant = create(:variant, product: create(:product, status: :archived))

          subject_1 = described_class.new(discontinued_variant)
          subject_2 = described_class.new(inactive_variant)

          expect(discontinued_variant.available?).to be false
          expect(inactive_variant.available?).to be false

          expect(subject_1.can_supply?).to be false
          expect(subject_2.can_supply?).to be false
        end
      end

      context 'when variant.should_track_inventory? is false' do
        let(:variant) { create(:variant, track_inventory: false) }
        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          expect(variant.should_track_inventory?).to be false
          expect(subject.can_supply?).to be true
        end
      end

      context 'when variant.backorderable? is true' do
        let(:variant) { create(:variant) }
        let(:stock_item) { create(:stock_item, backorderable: true, variant: variant) }

        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          expect(variant.backorderable?).to be true
          expect(subject.can_supply?).to be true
        end
      end

      context 'when variant.need_confirmation? is true' do
        let(:product) { create(:product, need_confirmation: true) }
        let(:variant) { create(:variant, product: product) }

        subject { described_class.new(variant) }

        it 'return can_supply? true' do
          expect(variant.need_confirmation?).to be true
          expect(subject.can_supply?).to be true
        end
      end
    end

    context 'check with redis after passed basic conditions above' do
      let(:variant) { create(:variant, track_inventory: true, discontinue_on: nil) }
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
    let(:cached_inventory_klass) { SpreeCmCommissioner::CachedInventoryItem }
    let(:cached_inventory_items) { [ cached_inventory_klass.new(inventory_key: "inventory:1", active: true, quantity_available: 5, inventory_item_id: 1, variant_id: variant.id ) ] }
    let(:options) { { from_date: Time.zone.today, to_date: Time.zone.tomorrow } }

    context 'when variant has permanent_stock (accomodation, transit, ...)' do
      let(:product) { create(:product, product_type: :accommodation) }
      let(:variant) { create(:variant, product: product) }

      subject { described_class.new(variant, options) }

      it 'fetch inventories key/quantity from VariantCachedInventoryItemsBuilder with :variant_id & date options' do
        expect_any_instance_of(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:call).once
        expect(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:new).with(
          variant_id: variant.id,
          from_date: options[:from_date],
          to_date: options[:to_date],
        ).once.and_call_original

        subject.cached_inventory_items
      end
    end

    context 'when variant has normal stock (ecommerce, ...)' do
      let(:product) { create(:product, product_type: :ecommerce) }
      let(:variant) { create(:variant, product: product) }

      subject { described_class.new(variant, options) }

      it 'fetch inventories key/quantity from VariantCachedInventoryItemsBuilder with just :variant_id' do
        expect(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:new).with(variant_id: variant.id).once.and_call_original
        expect_any_instance_of(SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder).to receive(:call).once

        subject.cached_inventory_items
      end
    end
  end
end
