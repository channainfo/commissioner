require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Vehicle < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::RouteType

    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType'
    has_one :primary_photo, -> { order(position: :asc) }, class_name: 'SpreeCmCommissioner::VehiclePhoto', as: :viewable, dependent: :destroy
    belongs_to :vendor, class_name: 'Spree::Vendor'

    before_save :set_route_type, if: :vehicle_type_id_changed?

    has_many :vehicle_photo, class_name: 'SpreeCmCommissioner::VehiclePhoto', as: :viewable, dependent: :destroy

    validates :code, uniqueness: { scope: :vendor_id }, presence: true
    validates :license_plate, uniqueness: {}, allow_blank: true
    validates :vehicle_type, presence: true

    def set_route_type
      self.route_type = vehicle_type.route_type
    end

    self.whitelisted_ransackable_attributes = %w[license_plate code]
    self.whitelisted_ransackable_associations = %w[vehicle_type]
  end
end
