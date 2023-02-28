require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  describe 'validations' do
    context 'state is either cart or address' do
      it 'not required present of email or phone number' do
        order = create(:order, state: 'cart')

        order.email = nil
        order.phone_number = nil

        expect(order.save).to eq true
      end
    end

    context 'state is not either cart or address' do
      it 'validates present of either email or phone number' do
        order = create(:order, state: 'payment')

        order.email = nil
        order.phone_number = nil

        expect { order.save! }
          .to raise_error(ActiveRecord::RecordInvalid)
          .with_message("Validation failed: Email can't be blank, Phone number can't be blank")
      end

      it 'not required phone number when email present' do
        order = create(:order, state: 'payment')

        order.email = 'test@gmail.com'
        order.phone_number = nil

        expect(order.save).to eq true
      end

      it 'not required email when phone number present' do
        order = create(:order, state: 'payment')

        order.email = nil
        order.phone_number = '+855 12345678'

        expect(order.save).to eq true
      end
    end
  end

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

  context 'callbacks' do
    describe 'before_save :sanitize_phone_number' do
      before(:each) do
        Phonelib.default_country = "KH"
      end

      it 'construct phone number before save' do
        order = build(:order, phone_number: '096 4103 875')

        expect(order.phone_number).to eq '096 4103 875'
        expect(order.intel_phone_number).to eq nil
        expect(order.country_code).to eq nil

        order.save!
        order.reload

        expect(order.phone_number).to eq '0964103875'
        expect(order.intel_phone_number).to eq '+855964103875'
        expect(order.country_code).to eq 'KH'
      end
    end
  end
end