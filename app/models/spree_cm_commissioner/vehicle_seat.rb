module SpreeCmCommissioner
  class VehicleSeat < SpreeCmCommissioner::Base
    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType'

    enum type: { :normal => 0, :empty => 1, :vip => 2, :driver => 3 }
  end
end
