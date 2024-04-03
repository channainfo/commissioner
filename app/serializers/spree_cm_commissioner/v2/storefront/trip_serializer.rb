module SpreeCmCommissioner
  module V2
    module Storefront
      class TripSerializer < BaseSerializer
        set_id :trip_id
        attributes :vendor_id, :vendor_name, :short_name, :route_name,
                   :origin_id, :origin, :destination_id, :destination,
                   :total_sold, :total_seats, :duration, :vehicle_id, :departure_time

        attribute :remaining_seats do |object|
          object.total_seats - object.total_sold
        end

        attribute :arrival_time do |object|
          (object.departure_time.to_time + object.duration.to_i.seconds).strftime('%H:%M')
        end

        attribute :duration_in_hms do |object|
          return '0h 0m 0s' if object.duration.nil?

          hours = object.duration / 3600
          minutes = (object.duration % 3600) / 60
          seconds = object.duration % 60
          "#{hours}h #{minutes}m #{seconds}s"
        end
      end
    end
  end
end
