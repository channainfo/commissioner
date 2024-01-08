module SpreeCmCommissioner
  class VehicleSeat < SpreeCmCommissioner::Base
    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType', dependent: :destroy

    enum seat_type: %i[normal empty vip driver].freeze
  end
end
