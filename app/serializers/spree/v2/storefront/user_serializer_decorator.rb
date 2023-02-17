module Spree
  module V2
    module Storefront
      module UserSerializerDecorator
        def self.prepended(base)
          base.attributes :first_name, :last_name
          base.has_one :profile, serializer: :user_profile
        end
      end
    end
  end
end

Spree::V2::Storefront::UserSerializer.prepend Spree::V2::Storefront::UserSerializerDecorator
