require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ReservationVariantQuantityAvailabilityQuery do
  describe '#booked_variants' do
    let!(:product) { create(:cm_accommodation_product, permanent_stock: 3) }

    context 'booked on 10th-12th: 0 left for 10th, 2 left for 11-12th' do
      let(:reservation1) { build(:order, state: :complete) }
      let(:reservation2) { build(:order, state: :complete) }

      let!(:line_item1) { create(:line_item, quantity: 3, order: reservation1, product: product, from_date: date('2023-01-10'), to_date: date('2023-01-11')) }
      let!(:line_item2) { create(:line_item, quantity: 1, order: reservation1, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-13')) }

      it 'return 2 available_quantity on 11th when inputs 9-11th' do
        subject = described_class.new(product.master.id, date('2023-01-09'), date('2023-01-11'))
        result = subject.booked_variants

        expect(result.size).to eq 2
        expect(result.keys).to eq (date('2023-01-10')..date('2023-01-11')).to_a

        expect(result[date('2023-01-10')]).to eq ({:variant_id => product.master.id, :permanent_stock => 3, :available_quantity => 0})
        expect(result[date('2023-01-11')]).to eq ({:variant_id => product.master.id, :permanent_stock => 3, :available_quantity => 2})
      end

      it 'return 2 available_quantity on 11-12th when inputs 10-13th' do
        subject = described_class.new(product.master.id, date('2023-01-10'), date('2023-01-13'))
        result = subject.booked_variants

        expect(result.size).to eq 3
        expect(result.keys).to eq (date('2023-01-10')..date('2023-01-12')).to_a

        expect(result[date('2023-01-10')]).to eq ({:variant_id => product.master.id, :permanent_stock => 3, :available_quantity => 0})
        expect(result[date('2023-01-11')]).to eq ({:variant_id => product.master.id, :permanent_stock => 3, :available_quantity => 2})
        expect(result[date('2023-01-12')]).to eq ({:variant_id => product.master.id, :permanent_stock => 3, :available_quantity => 2})
      end
    end
  end
end
