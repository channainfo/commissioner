class CreateSpreeCmCommissionerPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_permissions do |t|
      t.string :entry
      t.string :action
      t.index [:entry, :action], unique: true

      t.timestamps
    end
  end
end