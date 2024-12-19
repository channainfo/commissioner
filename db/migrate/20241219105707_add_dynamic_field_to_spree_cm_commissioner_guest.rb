class AddDynamicFieldToSpreeCmCommissionerGuest < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:cm_guests, :dynamic_field)
      add_column :cm_guests, :dynamic_field, :jsonb, default: {}
    end
  end
end
