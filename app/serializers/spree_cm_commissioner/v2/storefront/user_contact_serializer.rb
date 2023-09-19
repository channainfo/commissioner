module SpreeCmCommissioner
  module V2
    module Storefront
      class UserContactSerializer < BaseSerializer
        set_type :user

        attributes :email, :phone_number
      end
    end
  end
end
