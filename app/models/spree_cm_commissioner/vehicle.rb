require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Vehicle < SpreeCmCommissioner::Base
    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType', dependent: :destroy
    belongs_to :vendor, class_name: 'Spree::Vendor'

    has_many :vehicle_photo, class_name: 'SpreeCmCommissioner::VehiclePhoto', as: :viewable, dependent: :destroy

    validates :code, uniqueness: { scope: :vendor_id }, presence: true
    validates :license_plate, uniqueness: {}, allow_blank: true
    validates :vehicle_type, presence: true

    self.whitelisted_ransackable_attributes = %w[license_plate code]
    self.whitelisted_ransackable_associations = %w[vehicle_type]
  end
end
