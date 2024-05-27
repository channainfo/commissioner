require "spec_helper"

RSpec.describe Spree::Orders::GenerateCommissions do
  let(:vendor_a) { create(:vendor, commission_rate: 10) }
  let(:vendor_b) { create(:vendor, commission_rate: 15) }

  let(:product_a1) { create(:product_in_stock, vendor: vendor_a) }
  let(:product_a2) { create(:product_in_stock, vendor: vendor_a) }
  let(:product_b1) { create(:product_in_stock, vendor: vendor_b) }
  let(:product_b2) { create(:product_in_stock, vendor: vendor_b) }

  let(:line_item_a1) { create(:line_item, product: product_a1, price: 100) }
  let(:line_item_a2) { create(:line_item, product: product_a2, price: 100) }
  let(:line_item_b1) { create(:line_item, product: product_b1, price: 100) }
  let(:line_item_b2) { create(:line_item, product: product_b2, price: 100) }

  let(:order) { create(:order, state: :complete, line_items: [line_item_a1, line_item_a2, line_item_b1, line_item_b2])}

  subject { described_class.new }

  describe '#generate_commissions_group_by_vendor_ids' do
    it 'sum commission_amount of line items by vendor_id' do
      result = subject.generate_commissions_group_by_vendor_ids(order)

      # vendor_a
      expect(line_item_a1.commission_amount).to eq 10
      expect(line_item_a2.commission_amount).to eq 10

      # vendor_b
      expect(line_item_b1.commission_amount).to eq 15
      expect(line_item_b2.commission_amount).to eq 15

      expect(result.keys).to eq([vendor_a.id, vendor_b.id])
      expect(result[vendor_a.id]).to eq(10 + 10)
      expect(result[vendor_b.id]).to eq(15 + 15)
    end
  end

  describe '#generate_order_commissions' do
    context 'when order state is not complete' do

      it 'return failure?' do
        order.state = 'cart'

        result = subject.generate_order_commissions(order: order)

        expect(result.failure?).to eq true
      end
    end

    context 'when order state is complete' do
      it 'return generate commissions for order & return success' do
        result = subject.generate_order_commissions(order: order)

        expect(result.success?).to eq true
        expect(order.commissions.size).to eq 2

        expect(order.commissions[0].persisted?).to be true
        expect(order.commissions[0].vendor).to eq vendor_a
        expect(order.commissions[0].amount).to eq 10 + 10

        expect(order.commissions[1].persisted?).to be true
        expect(order.commissions[1].vendor).to eq vendor_b
        expect(order.commissions[1].amount).to eq 15 + 15
      end
    end
  end

  describe '#call' do
    context 'generate commission is called multiple time' do
      it 'raise error on second call' do
        first_run = described_class.new.call(order: order)
        expect(first_run.success?).to be true

        # second run
        expect{ described_class.new.call(order: order) }
          .to raise_error(ActiveRecord::RecordInvalid)
          .with_message("Validation failed: Vendor has already been taken")
      end
    end
  end
end
