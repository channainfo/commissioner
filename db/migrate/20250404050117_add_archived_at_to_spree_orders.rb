class AddArchivedAtToSpreeOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_orders, :archived_at, :datetime, if_not_exists: true
  end
end
