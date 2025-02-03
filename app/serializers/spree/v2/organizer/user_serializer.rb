module Spree
  module V2
    module Organizer
      class UserSerializer < BaseSerializer
        set_type :user

        attributes :first_name, :last_name, :gender, :email, :phone_number, :intel_phone_number
      end
    end
  end
end
