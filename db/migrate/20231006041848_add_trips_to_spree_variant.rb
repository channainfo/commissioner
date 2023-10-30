class AddTripsToSpreeVariant < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_variants, :trip_headsign, :string, if_not_exists: true
    add_column :spree_variants, :trip_short_name, :string, if_not_exists: true
    add_column :spree_variants, :trip_description, :string
    add_column :spree_variants, :service_id, :integer
    add_column :spree_variants, :auto_assigned_seat, :boolean, default: false
    add_column :spree_variants, :auto_sent_ticket, :boolean, default: true
    add_column :spree_variants, :must_select_intermediate_stop_seat, :boolean, default: true
    add_column :spree_variants, :skip_must_select_intermediate_stop_seat, :boolean, default: true
    add_column :spree_variants, :status, :boolean, default: true
  end
end
