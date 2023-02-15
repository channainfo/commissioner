require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  describe '#delivery_required?' do
    let(:product1) { create(:product, name: 'Product 1') }
    let(:product2) { create(:product, name: 'Product 2') }

    let(:line_item1) { create(:line_item, variant: product1.master) }
    let(:line_item2) { create(:line_item, variant: product2.master) }

    let(:order) { create(:order, line_items: [line_item1, line_item2]) }

    context 'required delivery' do
      it 'required delivery when all products are :ecommerce & not digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :ecommerce)

        allow(order.line_items[0]).to receive(:digital?).and_return(false)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq true
      end

      it 'required delivery when some of products are :ecommerce & not digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :service)

        allow(order.line_items[0]).to receive(:digital?).and_return(false)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq true
      end
    end

    context 'not required delivery' do
      it 'not required delivery when products are not :ecommerce (digital? are ignored this case)' do
        order.line_items[0].product.update_columns(product_type: :accommodation)
        order.line_items[1].product.update_columns(product_type: :service)

        expect(order.delivery_required?).to eq false
      end

      it 'not required delivery when some of products are :ecommerce & it is digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :service)

        allow(order.line_items[0]).to receive(:digital?).and_return(true)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq false
      end
    end
  end
end