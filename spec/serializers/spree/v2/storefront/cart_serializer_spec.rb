require 'spec_helper'

RSpec.describe Spree::V2::Storefront::CartSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:cart) { build(:order_with_line_items) }

    subject {
      described_class.new(cart, include: [
        :line_items,
        :variants,
        :promotions,
        :payments,
        :shipments,
        :user,
        :billing_address,
        :shipping_address,
        :vendors,
        :vendor_totals
      ]).serializable_hash
    }

    it 'returns exact cart attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :number,
        :item_total,
        :total,
        :ship_total,
        :adjustment_total,
        :created_at,
        :updated_at,
        :completed_at,
        :included_tax_total,
        :additional_tax_total,
        :display_additional_tax_total,
        :display_included_tax_total,
        :tax_total,
        :currency,
        :state,
        :token,
        :email,
        :display_item_total,
        :display_ship_total,
        :display_adjustment_total,
        :display_tax_total,
        :promo_total,
        :display_promo_total,
        :item_count,
        :special_instructions,
        :display_total,
        :pre_tax_item_amount,
        :display_pre_tax_item_amount,
        :pre_tax_total,
        :display_pre_tax_total,
        :shipment_state,
        :payment_state,
        :public_metadata,
        :phone_number,
        :intel_phone_number,
        :country_code,
        :request_state
      )
    end

    it 'returns exact cart relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :line_items,
        :variants,
        :promotions,
        :payments,
        :shipments,
        :user,
        :billing_address,
        :shipping_address,
        :vendors,
        :vendor_totals
      )
    end
  end
end