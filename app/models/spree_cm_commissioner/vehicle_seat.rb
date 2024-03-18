module SpreeCmCommissioner
  class VehicleSeat < SpreeCmCommissioner::Base
    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType', dependent: :destroy
    has_many :line_item_seats, class_name: 'SpreeCmCommissioner::LineItemSeat', dependent: :destroy
    counter_culture :vehicle_type, column_name: proc { |model|
                                                  model.seat_type.in?(%w[normal vip]) && model.vehicle_type.allow_seat_selection == true ? 'vehicle_seats_count' : nil # rubocop:disable Layout/LineLength
                                                },
                                   column_names: { ['cm_vehicle_seats.seat_type IN (?)', %i[0 2]] => 'vehicle_seats_count' }
    enum seat_type: %i[normal empty vip driver].freeze
  end
end
