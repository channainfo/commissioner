require 'spec_helper'

RSpec.describe Spree::Stock::AvailabilityValidator do
  context 'reservation?' do
    describe '#validate' do
      it 'always valid when it needs confirmation' do
        line_item = build(:line_item)
        allow(line_item).to receive(:need_confirmation?).and_return(true)

        described_class.new.validate(line_item)

        expect(line_item.errors.size).to eq 0
      end
    end

    describe '#validate_reservation' do
      let!(:product) { create(:cm_accommodation_product, permanent_stock: 3) }

      context 'booked on 10th-12th: 0 left for 10th, 2 left for 11-12th' do
        let(:reservation1) { build(:order, state: :complete) }
        let(:reservation2) { build(:order, state: :complete) }

        let!(:line_item1) { create(:line_item, quantity: 3, order: reservation1, product: product, from_date: date('2023-01-10'), to_date: date('2023-01-11'), accepted_at: date('2023-01-11')) }
        let!(:line_item2) { create(:line_item, quantity: 1, order: reservation2, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-13'), accepted_at: date('2023-01-11')) }

        it 'error when at least one day could not supply 3 quantity' do
          line_item = build(:line_item, quantity: 3, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date)
          described_class.new.send(:validate_reservation, line_item)

          expect(line_item.errors.full_messages).to eq ([
            "Quantity Rooms are not available on 2023-01-10",
            "Quantity Only 2 rooms available on 2023-01-11",
            "Quantity Only 2 rooms available on 2023-01-12"
          ])
        end

        it 'success when all day is available for 2 quantity' do
          line_item = build(:line_item, quantity: 2, product: product, from_date: '2023-01-11'.to_date, to_date: '2023-01-12'.to_date)
          described_class.new.send(:validate_reservation, line_item)

          expect(line_item.errors.size).to eq 0
        end
      end
    end
  end
end