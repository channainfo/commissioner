class AddPreferencesToSpreeCmCommissionerImport < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_imports, :preferences, :text, if_not_exists: true
  end
end
