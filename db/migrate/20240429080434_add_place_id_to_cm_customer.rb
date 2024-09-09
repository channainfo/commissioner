class AddPlaceIdToCmCustomer < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_customers, :place, foreign_key: { to_table: :cm_places }, index: true, if_not_exists: true
  end
end
