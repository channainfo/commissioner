class AddDefaultValueToSpreeAddressesGenderColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_default :spree_addresses, :gender, from: nil, to: 0
  end
end
