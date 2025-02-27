class AddIndexToEmailInSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    unless index_exists?(:spree_users, :email)
      add_index :spree_users, :email
    end
  end
end
