require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantAvailability::PermanentStockQuery do
  describe '#available?' do
    let(:variant) { create(:variant) }
    let(:available_quantity) { 2 }
    let(:desired_quantity) { 2 }

    before { variant.stock_items.first.adjust_count_on_hand(available_quantity) }

    context 'user want to book between 1st - 3rd July' do
      context 'when no dates is booked' do
        subject { described_class.new(variant: variant, from_date: date('2022-05-01'), to_date: date('2022-05-03')) }

        it 'return available true' do
          available = subject.available?(desired_quantity)
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

        subject { described_class.new(variant: variant, from_date: date('2022-05-01'), to_date: date('2022-05-03')) }

        it 'return available true' do
          available = subject.available?(desired_quantity)
          expect(available).to eq true
        end
      end

      context 'when one or more dates is booked for all desired_quantity' do
        # book all desired quantity on one or more dates
        let(:line_item_1st_to_2nd) { build(:line_item, quantity: available_quantity, from_date: date('2022-05-01'), to_date: date('2022-05-02'), variant: variant) }
        let(:line_item_3rd_to_4th) { build(:line_item, quantity: available_quantity, from_date: date('2022-05-03'), to_date: date('2022-05-04'), variant: variant) }
        let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item_1st_to_2nd, line_item_3rd_to_4th]) }

        subject { described_class.new(variant: variant, from_date: date('2022-05-01'), to_date: date('2022-05-03')) }

        it 'return available false' do
          available = subject.available?(desired_quantity)
          expect(available).to eq false
        end
      end
    end
  end
end