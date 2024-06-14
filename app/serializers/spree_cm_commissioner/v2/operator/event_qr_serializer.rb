module SpreeCmCommissioner
  module V2
    module Operator
      class EventQrSerializer < BaseSerializer
        attributes :qr_data, :expired_at
      end
    end
  end
end
