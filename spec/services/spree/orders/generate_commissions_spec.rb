require "spec_helper"

RSpec.describe Spree::Orders::GenerateCommissions do
  let(:vendor_a) { create(:vendor, commission_rate: 10) }
  let(:vendor_b) { create(:vendor, commission_rate: 15) }

  let(:product_a1) { create(:cm_product_in_stock, vendor: vendor_a, product_type: :ecommerce) }
  let(:product_a2) { create(:cm_product_in_stock, vendor: vendor_a, product_type: :ecommerce) }
  let(:product_b1) { create(:cm_product_in_stock, vendor: vendor_b, product_type: :ecommerce) }
  let(:product_b2) { create(:cm_product_in_stock, vendor: vendor_b, product_type: :ecommerce) }

  let(:variant_a1) { create(:cm_variant, product: product_a1) }
  let(:variant_a2) { create(:cm_variant, product: product_a2) }
  let(:variant_b1) { create(:cm_variant, product: product_b1) }
  let(:variant_b2) { create(:cm_variant, product: product_b2) }

  let(:line_item_a1) { create(:line_item, variant: variant_a1, price: 100) }
  let(:line_item_a2) { create(:line_item, variant: variant_a2, price: 100) }
  let(:line_item_b1) { create(:line_item, variant: variant_b1, price: 100) }
  let(:line_item_b2) { create(:line_item, variant: variant_b2, price: 100) }

  let(:order) { create(:order, state: :complete, line_items: [line_item_a1, line_item_a2, line_item_b1, line_item_b2])}

  subject { described_class.new }

  describe '#generate_commissions_group_by_vendor_ids' do
    it 'sum commission_amount of line items by vendor_id' do
      result = subject.generate_commissions_group_by_vendor_ids(order)

      # vendor_a
      expect(subject.commission_amount(line_item_a1)).to eq 10
      expect(subject.commission_amount(line_item_a2)).to eq 10

      # vendor_b
      expect(subject.commission_amount(line_item_b1)).to eq 15
      expect(subject.commission_amount(line_item_b2)).to eq 15

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
      it 'does not re-create if already exist' do
        first_run = described_class.new.call(order: order)
        expect(first_run.success?).to be true

        second_run = described_class.new.call(order: order)
        expect(second_run.success?).to be true

        third_run = described_class.new.call(order: order)
        expect(third_run.success?).to be true
      end
    end
  end
end
