module Spree
  module V2
    module Storefront
      class GuestUserSerializer < UserSerializer
        attribute :guest_token do |user|
          SpreeCmCommissioner::UserJwtToken.encode({ user_id: user.id }, user.secure_token)
        end
      end
    end
  end
end
