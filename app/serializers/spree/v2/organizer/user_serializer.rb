module Spree
  module V2
    module Organizer
      class UserSerializer < BaseSerializer
        attributes :first_name, :last_name, :email
      end
    end
  end
end
