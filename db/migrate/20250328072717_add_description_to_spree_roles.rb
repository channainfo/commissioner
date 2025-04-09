class AddDescriptionToSpreeRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_roles, :description, :text, if_not_exists: true
  end
end
