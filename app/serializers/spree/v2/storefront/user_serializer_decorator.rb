module Spree
  module V2
    module Storefront
      module UserSerializerDecorator
        def self.prepended(base)
          base.attributes :first_name, :last_name, :phone_number, :intel_phone_number, :country_code
          base.has_one :profile, serializer: :user_profile
          base.has_many :device_tokens, serializer: Spree::V2::Storefront::UserDeviceTokenSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::UserSerializer.prepend Spree::V2::Storefront::UserSerializerDecorator
