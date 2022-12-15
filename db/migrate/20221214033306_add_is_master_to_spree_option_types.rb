class AddIsMasterToSpreeOptionTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_option_types, :is_master, :boolean, null: false, default: false
  end
end
