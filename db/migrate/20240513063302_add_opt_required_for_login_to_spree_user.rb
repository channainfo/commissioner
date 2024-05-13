class AddOptRequiredForLoginToSpreeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :opt_required_for_login, :boolean, default: false
  end
end
