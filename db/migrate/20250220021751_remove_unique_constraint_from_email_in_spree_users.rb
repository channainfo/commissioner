class RemoveUniqueConstraintFromEmailInSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    if index_exists?(:spree_users, :email, unique: true)
      remove_index :spree_users, :email
    end
  end
end
