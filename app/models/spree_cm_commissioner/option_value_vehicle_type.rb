require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class OptionValueVehicleType < ApplicationRecord
    belongs_to :vehicle_type, class_name: 'SpreeCmCommissioner::VehicleType', dependent: :destroy
    belongs_to :option_value, class_name: 'Spree::OptionValue', dependent: :destroy
  end
end
