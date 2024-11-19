module SpreeCmCommissioner
  module V2
    module Storefront
      class WaitingRoomSessionSerializer < BaseSerializer
        attributes :jwt_token, :expired_at
      end
    end
  end
end
