require 'spec_helper'

RSpec.describe Spree::Stock::AvailabilityValidator do
  context 'reservation?' do
    describe '#validate_reservation' do
      let!(:product) { create(:cm_accommodation_product, permanent_stock: 3) }

      context 'booked on 10th-12th: 0 left for 10th, 2 left for 11-12th' do
        before(:each) do
          reservation1 = build(:order, state: :complete)
          reservation2 = build(:order, state: :complete)

          create(:line_item, quantity: 1, order: reservation1, product: product, from_date: date('2023-01-10'), to_date: date('2023-01-11'))
          create(:line_item, quantity: 2, order: reservation1, product: product, from_date: date('2023-01-12'), to_date: date('2023-01-13'))
        end

        it 'error when at least one day could not supply 2 quantity' do
          line_item = build(:line_item, quantity: 2, product: product, from_date: '2023-01-11'.to_date, to_date: '2023-01-12'.to_date)
          described_class.new.send(:validate, line_item)

          expect(line_item.errors.full_messages).to eq (["Quantity Only 1 room available on 2023-01-12"])
        end

        it 'success when all day is available for 2 quantity' do
          line_item = build(:line_item, quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-11'.to_date)
          described_class.new.send(:validate, line_item)

          expect(line_item.errors.size).to eq 0
        end
      end
    end
  end
end