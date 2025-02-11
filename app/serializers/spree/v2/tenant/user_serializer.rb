module Spree
  module V2
    module Tenant
      class UserSerializer < BaseSerializer
        attributes :email, :first_name, :last_name, :gender,
                   :public_metadata, :completed_orders,
                   :phone_number, :intel_phone_number, :country_code,
                   :otp_enabled, :otp_email, :otp_phone_number,
                   :confirm_pin_code_enabled

        has_one :profile, serializer: Spree::V2::Tenant::AssetSerializer
        has_many :device_tokens, serializer: Spree::V2::Tenant::UserDeviceTokenSerializer
        has_many :spree_roles, serializer: Spree::V2::Tenant::RoleSerializer

        attribute :store_credits, &:total_available_store_credit

        attribute :completed_orders do |object|
          object.orders.complete.count
        end

        has_one :default_billing_address,
                id_method_name: :bill_address_id,
                object_method_name: :bill_address,
                record_type: :address,
                serializer: :address

        has_one :default_shipping_address,
                id_method_name: :ship_address_id,
                object_method_name: :ship_address,
                record_type: :address,
                serializer: :address
      end
    end
  end
end
