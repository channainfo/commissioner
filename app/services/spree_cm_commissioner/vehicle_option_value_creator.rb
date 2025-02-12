module SpreeCmCommissioner
  class VehicleOptionValueCreator
    def self.call(vehicle)
      vehicle_option_type = Spree::OptionType.vehicle

      value = vehicle_option_type.option_values.where(name: vehicle.id).first_or_initialize
      value.presentation = vehicle.code
      value.save
    end
  end
end
