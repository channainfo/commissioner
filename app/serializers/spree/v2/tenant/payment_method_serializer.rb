module Spree
  module V2
    module Tenant
      class PaymentMethodSerializer < BaseSerializer
        attributes :type, :name, :description, :public_metadata

        attribute :preferences do |object|
          object.public_preferences.as_json
        end

        attribute :icon_name do |payment_method|
          return nil if payment_method.preferences.blank?

          payment_method.preferences[:icon_name]
        end

        attribute :payment_option do |payment_method|
          pref = payment_method.preferences

          pref.blank? || pref[:payment_option].blank? ? payment_method.method_type : pref[:payment_option]
        end
      end
    end
  end
end
