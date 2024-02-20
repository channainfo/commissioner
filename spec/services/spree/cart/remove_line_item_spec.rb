require "spec_helper"

RSpec.describe Spree::Cart::RemoveLineItem do
  describe '#call' do
    let(:order) { create(:order) }
    let!(:line_item_a) { create(:line_item, order: order, price: BigDecimal('10.00'), quantity: 1) }
    let!(:line_item_b) { create(:line_item, order: order, price: BigDecimal('12.00'), quantity: 1) }

    it 'should recaculate correct order total after line items is removed' do
      result = Spree::Cart::RemoveLineItem.new.call(order: order, line_item: line_item_a)

      expect(order.total).to eq line_item_b.amount
    end
  end
end
