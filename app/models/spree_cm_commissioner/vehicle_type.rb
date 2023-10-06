module SpreeCmCommissioner
  class VehicleType < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::RouteType
    has_many :vehicle_seats, class_name: 'SpreeCmCommissioner::VehicleSeat'
    belongs_to :vendor, class_name: 'Spree::Vendor'

    accepts_nested_attributes_for :vehicle_seats, allow_destroy: true
  end
end
