class AddStateIdToSpreeCmCommissionerPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :state_id, :int, if_not_exists: true
  end
end
