module Spree
  module V2
    module Storefront
      module UserSerializerDecorator
        def self.prepended(base)
          base.attributes :first_name, :last_name, :gender, :phone_number, :intel_phone_number, :country_code, :opt_required_for_login
          base.has_one :profile, serializer: ::Spree::V2::Storefront::UserProfileSerializer
          base.has_many :device_tokens, serializer: Spree::V2::Storefront::UserDeviceTokenSerializer
          base.has_many :spree_roles, serializer: Spree::V2::Storefront::RoleSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::UserSerializer.prepend Spree::V2::Storefront::UserSerializerDecorator
