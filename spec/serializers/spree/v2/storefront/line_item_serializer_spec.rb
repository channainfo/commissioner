require 'spec_helper'

RSpec.describe Spree::V2::Storefront::LineItemSerializer, type: :serializer do
  describe '#serializable_hash' do
  product = Spree::Product.create(name: 'Test Product', price: 10.00, product_type: :accommodation)
  line_item = Spree::LineItem.new(quantity: 1, price: 10.00, currency: 'USD', product: product)

    subject {
      described_class.new(line_item, include: [
        :variant,
        :digital_links,
        :vendor
      ]).serializable_hash
    }

    it 'returns exact accommodations attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :quantity,
        :price,
        :slug,
        :options_text,
        :currency,
        :display_price,
        :total,
        :display_total,
        :adjustment_total,
        :display_adjustment_total,
        :additional_tax_total,
        :discounted_amount,
        :display_discounted_amount,
        :display_additional_tax_total,
        :promo_total,
        :display_promo_total,
        :included_tax_total,
        :display_included_tax_total,
        :pre_tax_amount,
        :display_pre_tax_amount,
        :public_metadata,
        :from_date,
        :to_date,
        :vendor_id,
        :need_confirmation
      )
    end

    it 'returns exact accommodation relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :variant,
        :digital_links,
        :vendor
      )
    end
  end
end
