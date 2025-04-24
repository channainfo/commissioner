module Spree
  module V2
    module Tenant
      class UserContactSerializer < BaseSerializer
        set_type :user

        attributes :email, :phone_number
      end
    end
  end
end
