require 'spec_helper'

describe Spree::V2::Tenant::UserSerializer, type: :serializer do
  describe '#serializable_hash' do
    let(:user) { create(:user) }

    subject {
      described_class.new(user, include: [
        :default_billing_address,
        :default_shipping_address,
        :profile
      ]).serializable_hash
    }

    it 'returns exact user attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :email,
        :first_name,
        :last_name,
        :gender,
        :dob,
        :public_metadata,
        :store_credits,
        :completed_orders,
        :phone_number,
        :intel_phone_number,
        :country_code,
        :otp_enabled,
        :otp_email,
        :otp_phone_number,
        :confirm_pin_code_enabled
      )
    end

    it 'returns exact user relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :default_billing_address,
        :default_shipping_address,
        :profile,
        :device_tokens,
        :spree_roles
      )
    end
  end
end
