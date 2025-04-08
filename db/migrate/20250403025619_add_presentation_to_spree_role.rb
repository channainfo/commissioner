class AddPresentationToSpreeRole < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_roles, :presentation, :string, if_not_exists: true
  end
end
