class UpdateCounterCacheOfVehicleType < ActiveRecord::Migration[7.0]
    def up
      SpreeCmCommissioner::VehicleSeat.counter_culture_fix_counts
    end
end
