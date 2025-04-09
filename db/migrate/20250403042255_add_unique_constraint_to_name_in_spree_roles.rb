class AddUniqueConstraintToNameInSpreeRoles < ActiveRecord::Migration[7.0]
  def change
    unless index_exists?(:spree_roles, :name, unique: true)
      add_index :spree_roles, :name, unique: true
    end
  end
end
