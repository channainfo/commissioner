class ChangeTypeColumnInSpreeCmCommissionerPincodes < ActiveRecord::Migration[7.0]
  def up
    change_column :cm_pin_codes, :type, :string, limit:60 
  end

  def down
    change_column :cm_pin_codes, :type, :text, limit: 60
  end
end

