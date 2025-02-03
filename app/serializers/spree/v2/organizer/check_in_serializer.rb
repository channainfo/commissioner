module Spree
  module V2
    module Organizer
      class CheckInSerializer < BaseSerializer
        set_type :check_in

        attributes :guest_id,
                   :verification_state,
                   :check_in_type,
                   :entry_type,
                   :check_in_method,
                   :confirmed_at,
                   :token

        belongs_to :check_in_by, serializer: ::Spree::V2::Organizer::UserSerializer
        belongs_to :guest, serializer: ::Spree::V2::Organizer::GuestSerializer
      end
    end
  end
end
