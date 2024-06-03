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

      context 'when variant stock is permanent' do
        before { allow(variant).to receive(:permanent_stock?).and_return(true) }

        it 'call available_between_date_range?() method' do
          quantity = 1
          options = { from_date: Time.current, to_date: Time.current + 2.days }

          expect(subject).to receive(:available_between_date_range?).with(quantity, options)

          subject.can_supply?(quantity, options)
        end
      end

      context 'when variant stock is not permanent' do
        before { allow(variant).to receive(:permanent_stock?).and_return(false) }

        it 'call available?() method' do
          quantity = 1
          options = {}

          expect(subject).to receive(:available?).with(quantity, options)

          subject.can_supply?(quantity, options)
        end
      end
    end
  end

  describe '#available? (for non permanent stock product)' do
    let(:variant) { create(:variant) }
    let(:available_quantity) { 2 }

    subject { described_class.new(variant) }
    before { variant.stock_items.first.adjust_count_on_hand(available_quantity) }

    context 'user want to purchase 1 quantity' do
      context 'when have 1 remaining in stock' do
        let(:line_item) { build(:line_item, quantity: 1, variant: variant) }
        let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item]) }

        it 'return available true' do
          available = subject.available?(1)

          expect(available).to eq true
        end
      end

      context 'when have 0 remaining in stock' do
        let(:line_item) { build(:line_item, quantity: 2, variant: variant) }
        let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item]) }

        it 'return available true' do
          available = subject.available?(1)
          expect(available).to eq false
        end
      end
    end
  end

  describe '#available_between_date_range? (for permanent stock product)' do
    let(:variant) { create(:variant) }
    let(:available_quantity) { 2 }
    let(:desired_quantity) { 2 }

    subject { described_class.new(variant) }
    before { variant.stock_items.first.adjust_count_on_hand(available_quantity) }

    context 'user want to book between 1st - 3rd July' do
      context 'when no dates is booked' do
        it 'return available true' do
          available = subject.available_between_date_range?(desired_quantity, { from_date: date('2022-05-01'), to_date: date('2022-05-03') })
          expect(available).to eq true
        end
      end

      context 'when one or more dates are booked but desired_quantity still available' do
        # overrided
        let(:available_quantity) { 4 }
        let(:desired_quantity) { 2 }

        # book some quantity on one or more dates
        let(:line_item_1st_to_2nd) { build(:line_item, quantity: available_quantity - desired_quantity, from_date: date('2022-05-01'), to_date: date('2022-05-02'), variant: variant) }
        let(:line_item_3rd_to_4th) { build(:line_item, quantity: available_quantity - desired_quantity, from_date: date('2022-05-03'), to_date: date('2022-05-04'), variant: variant) }
        let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item_1st_to_2nd, line_item_3rd_to_4th]) }

        it 'return available true' do
          available = subject.available_between_date_range?(desired_quantity, { from_date: date('2022-05-01'), to_date: date('2022-05-03') })
          expect(available).to eq true
        end
      end

      context 'when one or more dates is booked for all desired_quantity' do
        # book all desired quantity on one or more dates
        let(:line_item_1st_to_2nd) { build(:line_item, quantity: available_quantity, from_date: date('2022-05-01'), to_date: date('2022-05-02'), variant: variant) }
        let(:line_item_3rd_to_4th) { build(:line_item, quantity: available_quantity, from_date: date('2022-05-03'), to_date: date('2022-05-04'), variant: variant) }
        let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item_1st_to_2nd, line_item_3rd_to_4th]) }

        it 'return available false' do
          available = subject.available_between_date_range?(desired_quantity, { from_date: date('2022-05-01'), to_date: date('2022-05-03') })
          expect(available).to eq false
        end
      end
    end
  end
end