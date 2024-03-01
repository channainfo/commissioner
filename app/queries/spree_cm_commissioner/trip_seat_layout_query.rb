require 'date'
module SpreeCmCommissioner
  class TripSeatLayoutQuery
    attr_reader :trip_id, :date, :vehicle_type

    def initialize(trip_id:, date:)
      @trip_id = trip_id
      @date = date
    end

    def call
      route = Spree::Variant.find_by(id: trip_id).product
      vehicle = SpreeCmCommissioner::Vehicle.find_by(id: route.vehicle_id)
      @vehicle_type = SpreeCmCommissioner::VehicleType.find_by(id: vehicle.vehicle_type_id)

      # layout_structure
      # {"First_Layer" => {"Row_1" => [{seat1}, {seat2}, {seat3}, {seat4}],
      #                   {"Row_2" => [{seat5}, {seat6}, {seat7}, {seat8}],
      # }
      seats.group_by(&:layer).transform_values do |seats|
        seats.group_by(&:row).transform_values do |row_seats|
          row_seats.sort_by(&:column).map do |seat|
            {
              row: seat.row,
              column: seat.column,
              label: seat.label,
              layer: seat.layer,
              seat_type: seat.seat_type,
              created_at: seat.created_at,
              seat_id: seat.seat_id,
              vehicle_type_id: seat.vehicle_type_id
            }
          end
        end
      end
    end

    def seats
      # check line_item status
      SpreeCmCommissioner::VehicleSeat.select('cm_vehicle_seats.*, cm_line_item_seats.seat_id')
                                      .joins("LEFT JOIN cm_line_item_seats ON cm_vehicle_seats.id = cm_line_item_seats.seat_id
                                              AND cm_line_item_seats.variant_id = #{trip_id}
                                              AND cm_line_item_seats.date = '#{date}'
                                              "
                                            )
                                      .where('cm_vehicle_seats.vehicle_type_id = ? ', vehicle_type.id)
    end
  end
end
