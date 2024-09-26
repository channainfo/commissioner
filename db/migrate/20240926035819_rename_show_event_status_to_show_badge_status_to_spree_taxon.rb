class RenameShowEventStatusToShowBadgeStatusToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    rename_column :spree_taxons, :show_event_status, :show_badge_status
    change_column :spree_taxons, :show_badge_status, :boolean, default: false
  end
end
