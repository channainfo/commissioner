class CreateCmTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_tenants, if_not_exists: true do |t|
      t.string :name
      t.timestamps
    end
  end
end
