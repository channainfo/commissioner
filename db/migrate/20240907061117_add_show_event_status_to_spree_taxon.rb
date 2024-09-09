class AddShowEventStatusToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :show_event_status, :boolean, if_not_exists: true
  end
end
