class AddAgeAndGenderToSpreeAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_addresses, :age, :integer
    add_column :spree_addresses, :gender, :integer
  end
end
