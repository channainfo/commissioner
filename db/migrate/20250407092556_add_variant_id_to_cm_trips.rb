class AddVariantIdToCmTrips < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:cm_trips, :variant_id)
      add_reference :cm_trips, :variant, foreign_key: { to_table: :spree_variants }
    end
  end
end
