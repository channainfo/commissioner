class AddHiddenToSpreeOptionType < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_option_types, :hidden, :boolean, default: false, if_not_exists: true
  end
end
