class UpdateNumberOfSeatsOfVehicle < ActiveRecord::Migration[7.0]
  def change
    SpreeCmCommissioner::Vehicle.find_each do |vehicle|
      vehicle.set_attributes
      vehicle.save
    end
  end
end
