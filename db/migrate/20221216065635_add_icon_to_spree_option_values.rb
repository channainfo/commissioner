class AddIconToSpreeOptionValues < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_option_values, :icon, :string
  end
end
