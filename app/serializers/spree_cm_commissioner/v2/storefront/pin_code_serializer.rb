module SpreeCmCommissioner
  module V2
    module Storefront
      class PinCodeSerializer < BaseSerializer
        set_type :pin_code

        attribute :token, :type, :contact_type, :contact
      end
    end
  end
end
