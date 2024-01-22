require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Cart::SetQuantity do
  let(:order) { create(:order) }
  let(:variant) { create(:variant) }
  let(:guest1) { create(:guest) }
  let(:guest2) { create(:guest) }
  let(:line_item) { create(:line_item, variant: variant, order: order, quantity: 4, guests: [guest1, guest2])}

  context "it removes guests and set quantity" do
    it "removes 1 saved guests" do
      expect_line_item_quantity = 3
      described_class.call(order: order, line_item: line_item, quantity: 3, guests_to_remove: [guest1.id])
      expect(line_item.quantity).to eq expect_line_item_quantity
      p line_item.guests
    end

    it "removes 2 saved guests" do
      expect_line_item_quantity = 2
      described_class.call(order: order, line_item: line_item, quantity: 2, guests_to_remove: [guest1.id, guest2.id])
      expect(line_item.quantity).to eq expect_line_item_quantity
      p line_item.guests
    end

    it "removes unsaved guests by set line item quantity" do
      expect_line_item_quantity = 2
      described_class.call(order: order, line_item: line_item, quantity: 2, guests_to_remove: nil)
      expect(line_item.quantity).to eq expect_line_item_quantity
      p line_item.guests
    end
  end
end
