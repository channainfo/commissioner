require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VariantAvailability::NonPermanentStockQuery do
  describe '#available?' do
    let(:variant) { create(:variant) }
    let(:available_quantity) { 2 }

    subject { described_class.new(variant: variant) }

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

    context 'when previously has multiple purchased line items' do
      let(:available_quantity) { 5 }

      let(:line_item1) { build(:line_item, quantity: 2, variant: variant) }
      let(:line_item2) { build(:line_item, quantity: 2, variant: variant) }
      let!(:order) { create(:order, state: :complete, completed_at: Date.current, line_items: [line_item1, line_item2]) }

      it 'return availability when remaining 1' do
        expect(subject.available?(1)).to eq true
        expect(subject.available?(2)).to eq false
        expect(subject.available?(3)).to eq false
        expect(subject.available?(4)).to eq false
      end
    end

    context 'when previously has no purchased line items' do
      let(:available_quantity) { 5 }

      it 'return availability base on quantity' do
        expect(subject.available?(5)).to eq true
        expect(subject.available?(6)).to eq false
        expect(subject.available?(8)).to eq false
      end
    end
  end
end
