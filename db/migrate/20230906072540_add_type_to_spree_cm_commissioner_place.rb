class AddTypeToSpreeCmCommissionerPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :type, :string, null: true, if_not_exists: true
  end
end
