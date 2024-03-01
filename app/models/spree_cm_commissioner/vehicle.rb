require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Vehicle < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::RouteType

    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType'
    has_one :primary_photo, -> { order(position: :asc) }, class_name: 'SpreeCmCommissioner::VehiclePhoto', as: :viewable, dependent: :destroy
    belongs_to :vendor, class_name: 'Spree::Vendor'

    before_save :set_attributes
    after_commit :create_vehicle_option_value

    has_many :vehicle_photo, class_name: 'SpreeCmCommissioner::VehiclePhoto', as: :viewable, dependent: :destroy
    has_many :vehicle_seats, class_name: 'SpreeCmCommissioner::VehicleSeat', through: :vehicle_type

    validates :code, uniqueness: { scope: :vendor_id }, presence: true
    validates :license_plate, uniqueness: {}, allow_blank: true
    validates :vehicle_type, presence: true

    def set_attributes
      self.route_type = vehicle_type.route_type
      self.number_of_seats = vehicle_type.vehicle_seats_count
    end

    # TODO: Move to service object
    def create_vehicle_option_value
      SpreeCmCommissioner::VehicleOptionValueCreator.call(self)
    end

    self.whitelisted_ransackable_attributes = %w[license_plate code]
    self.whitelisted_ransackable_associations = %w[vehicle_type]
  end
end
