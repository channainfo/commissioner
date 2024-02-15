class AddBadgeToSpreeMenuItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_menu_items, :badge, :string, if_not_exists: true
  end
end
