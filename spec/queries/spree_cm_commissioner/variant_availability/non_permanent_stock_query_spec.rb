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
  end
end