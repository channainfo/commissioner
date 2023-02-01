class AddFieldsToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :first_name, :string, if_not_exists: true
    add_column :spree_users, :last_name, :string , if_not_exists: true
    add_column :spree_users, :gender, :integer   , if_not_exists: true
    add_column :spree_users, :dob, :date         , if_not_exists: true
  end
end
