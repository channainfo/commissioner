module SpreeCmCommissioner
  class VehicleSeat < SpreeCmCommissioner::Base

    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType'
  end
end
