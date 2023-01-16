class AddFieldsToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :first_name, :string
    add_column :spree_users, :last_name, :string
    add_column :spree_users, :gender, :integer
    add_column :spree_users, :dob, :date
  end
end
