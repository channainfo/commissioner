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

      context 'when variant.delivery_required? is true (it check stock base on default spree instead)' do
        let(:product) { create(:product, product_type: :ecommerce) }
        let(:variant) { create(:variant, product: product) }
        let!(:stock_item) do
          stock_item = variant.stock_items.first
          stock_item.backorderable = false
          stock_item.set_count_on_hand(3)
          stock_item
        end

        subject { described_class.new(variant) }

        context 'stock items is available' do
          it 'return can_supply? true' do
            allow(variant).to receive(:delivery_required?).and_return(true)

            expect(subject.can_supply?(3)).to be true
          end
        end

        context 'stock items is not available' do
          it 'return can_supply? false' do
            allow(variant).to receive(:delivery_required?).and_return(true)

            expect(subject.can_supply?(4)).to be false
          end
        end
      end
    end

    context 'real time validation conditions (after passed basic conditions above)' do
      let(:variant) { create(:variant, track_inventory: true, discontinue_on: nil) }
      subject { described_class.new(variant) }

      before do
        variant.stock_items.update_all(backorderable: false)
        expect(variant.available?).to be true
        expect(variant.should_track_inventory?).to be true
        expect(variant.backorderable?).to be false
        expect(variant.need_confirmation?).to be false
      end

      context 'when variant stock is not permanent' do
        before { allow(variant).to receive(:permanent_stock?).and_return(false) }

        it 'call variant_available?() method' do
          quantity = 1
          options = {}

          expect(subject).to receive(:variant_available?).with(quantity, options)

          subject.can_supply?(quantity, options)
        end
      end

      context 'when variant stock is permanent' do
        before { allow(variant).to receive(:permanent_stock?).and_return(true) }

        it 'call permanent_stock_variant_available?() method' do
          quantity = 1
          options = { from_date: Time.current, to_date: Time.current + 2.days }

          expect(subject).to receive(:permanent_stock_variant_available?).with(quantity, options)

          subject.can_supply?(quantity, options)
        end
      end
    end
  end

  describe '#variant_available?' do
    let(:querier_klass) { SpreeCmCommissioner::VariantAvailability::NonPermanentStockQuery }

    let(:variant) { create(:variant) }
    let(:options) { { except_line_item_id: 1 } }
    let(:checking_quantity) { 1 }
    let(:querier) { querier_klass.new(variant: variant, except_line_item_id: 1) }

    subject { described_class.new(variant) }

    it 'construct NonPermanentStockQuery instance & call available?' do
      expect(querier_klass)
        .to receive(:new)
        .with(variant: variant, except_line_item_id: 1)
        .and_return(querier)

      expect(querier).to receive(:available?)
        .with(checking_quantity)
        .and_call_original

      subject.variant_available?(checking_quantity, options)
    end

    context '(no mock) when variant still in stock' do
      let(:variant) { create(:variant) }
      let(:available_quantity) { 2 }

      subject { described_class.new(variant) }
      before { variant.stock_items.first.adjust_count_on_hand(available_quantity) }

      it 'return available true' do
        expect(subject.variant_available?(1)).to be true
      end
    end
  end

  describe '#permanent_stock_variant_available?' do
    let(:querier_klass) { SpreeCmCommissioner::VariantAvailability::PermanentStockQuery }

    let(:variant) { create(:variant) }
    let(:options) { { except_line_item_id: 1, from_date: date('2022-05-01'), to_date: date('2022-05-01') } }
    let(:checking_quantity) { 1 }

    let(:querier) do
      querier_klass.new(
        variant: variant,
        from_date: options[:from_date],
        to_date: options[:to_date],
        except_line_item_id: 1,
      )
    end

    subject { described_class.new(variant) }

    it 'construct PermanentStockQuery instance & call available?' do
      expect(querier_klass)
        .to receive(:new)
        .with(variant: variant, from_date: options[:from_date], to_date: options[:to_date], except_line_item_id: 1)
        .and_return(querier)

      expect(querier).to receive(:available?)
        .with(checking_quantity)
        .and_call_original

      subject.permanent_stock_variant_available?(checking_quantity, options)
    end

    context '(no mock) when variant still in stock on desired date' do
      subject { described_class.new(variant) }

      let(:options) { { from_date: date('2022-05-01'), to_date: date('2022-05-03') } }

      it 'return available true' do
        expect(subject.permanent_stock_variant_available?(1, options)).to eq true
      end
    end
  end
end
