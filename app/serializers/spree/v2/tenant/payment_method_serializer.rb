module Spree
  module V2
    module Tenant
      class PaymentMethodSerializer < BaseSerializer
        attributes :type, :name, :description, :public_metadata

        attribute :preferences do |object|
          object.public_preferences.as_json
        end
      end
    end
  end
end
