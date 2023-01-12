module Spree
  module V2
    module Storefront
      class UserProfileSerializer < BaseSerializer
        set_type :user_profile

        attributes :styles
      end
    end
  end
end
