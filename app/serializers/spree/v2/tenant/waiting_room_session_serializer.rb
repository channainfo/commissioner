module Spree
  module V2
    module Tenant
      class WaitingRoomSessionSerializer < BaseSerializer
        attributes :jwt_token, :expired_at
      end
    end
  end
end
