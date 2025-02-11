module SpreeCmCommissioner
  module V2
    module Storefront
      class TripLayoutSerializer < BaseSerializer
        set_id :trip_id
        attributes :total_sold, :total_seats, :remaining_seats, :allow_seat_selection, :vehicle_type_id, :layers
      end
    end
  end
end
