class RemoveUniqueConstraintFromNameInSpreeRoles < ActiveRecord::Migration[7.0]
  def change
    if index_exists?(:spree_roles, :name, unique: true)
      remove_index :spree_roles, :name
    end
  end
end
