class AddPermanentStockToSpreeVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_variants, :permanent_stock, :integer, default: 1, if_not_exists: true
  end
end
