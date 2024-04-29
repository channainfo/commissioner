module SpreeCmCommissioner
  class TripSeatLayoutQuery
    attr_reader :trip_id, :date, :vehicle_type, :vehicle, :route

    def initialize(trip_id:, date:)
      @trip_id = trip_id
      @date = date
      @route = Spree::Variant.find_by(id: trip_id).product
      @vehicle = SpreeCmCommissioner::Vehicle.find_by(id: route.trip.vehicle_id)
      @vehicle_type = SpreeCmCommissioner::VehicleType.find_by(id: vehicle.vehicle_type_id)
    end

    def call
      allow_seat_selection = @route.trip.allow_seat_selection
      total_sold, remaining_seats, layers = process_seat_selection(allow_seat_selection)

      SpreeCmCommissioner::TripSeatLayoutResult.new({ trip_id: trip_id, total_sold: total_sold,
                                                      total_seats: vehicle.number_of_seats,
                                                      remaining_seats: remaining_seats,
                                                      allow_seat_selection: allow_seat_selection,
                                                      layers: layers
                                                    }
      )
    end

    def process_seat_selection(allow_seat_selection)
      # layout_structure
      # {"First_Layer" => {"Row_1" => [{seat1}, {seat2}, {seat3}, {seat4}],
      #                   {"Row_2" => [{seat5}, {seat6}, {seat7}, {seat8}],
      # }
      if allow_seat_selection
        vehicle_seats = seats.to_a
        total_sold = vehicle_seats.count { |s| s.seat_id.present? }
        remaining_seats = vehicle.number_of_seats - total_sold
        layers = vehicle_seats.group_by(&:layer).map do |layer_name, seats|
          {
            name: layer_name,
            rows: seats.group_by(&:row).map do |row_number, row_seats|
              {
                number: row_number,
                columns: row_seats.sort_by(&:column).map do |seat|
                  {
                    number: seat.column,
                    label: seat.label,
                    seat_type: seat.seat_type,
                    created_at: seat.created_at.iso8601, # Formatting datetime to ISO 8601 string
                    seat_id: seat.seat_id,
                    vehicle_type_id: seat.vehicle_type_id
                  }
                end
              }
            end
          }
        end
      else
        total_sold = Spree::LineItem.joins(:order)
                                    .where(variant_id: trip_id, date: date, spree_orders: { state: 'complete' })
                                    .sum(:quantity)
        remaining_seats = vehicle.number_of_seats - total_sold
        layers = nil
      end

      [total_sold, remaining_seats, layers]
    end

    def seats
      SpreeCmCommissioner::VehicleSeat.select('cm_vehicle_seats.*, os.seat_id as seat_id')
                                      .joins("LEFT JOIN (#{ordered_seats.to_sql}) os ON cm_vehicle_seats.id = os.seat_id")
                                      .where('cm_vehicle_seats.vehicle_type_id = ? ', vehicle_type.id)
    end

    def ordered_seats
      SpreeCmCommissioner::LineItemSeat.select('cm_line_item_seats.seat_id')
                                       .joins('INNER JOIN spree_line_items ON cm_line_item_seats.line_item_id = spree_line_items.id')
                                       .joins('INNER JOIN spree_orders ON spree_orders.id = spree_line_items.order_id')
                                       .where('spree_orders.state = ? ', 'complete')
                                       .where('cm_line_item_seats.variant_id = ? AND cm_line_item_seats.date = ?', trip_id, date)
    end
  end
end
