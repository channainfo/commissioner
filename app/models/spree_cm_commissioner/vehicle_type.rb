module SpreeCmCommissioner
  class VehicleType < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::RouteType
    has_many :vehicle_seats, class_name: 'SpreeCmCommissioner::VehicleSeat'
    belongs_to :vendor, class_name: 'Spree::Vendor'

    accepts_nested_attributes_for :vehicle_seats, allow_destroy: true

    def seat_layers
      grouped_seats = SpreeCmCommissioner::VehicleSeat.where(vehicle_type_id: id).group_by(&:layer).transform_values do |seats|
        seats.group_by(&:row).transform_values do |row_seats|
          row_seats.sort_by(&:column).map do |seat|
            {
              row: seat.row,
              column: seat.column,
              label: seat.label,
              layer: seat.layer,
              seat_type: seat.seat_type,
              vehicle_type_id: seat.vehicle_type_id
            }
          end
        end
      end
      grouped_seats.map do |_layer, layer_seats|
        layer_seats.map do |_row, row_seats|
          row_seats
        end
      end
    end
  end
end
