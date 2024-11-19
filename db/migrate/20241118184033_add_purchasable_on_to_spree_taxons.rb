class AddPurchasableOnToSpreeTaxons < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :purchasable_on, :integer, null: false, default: 0, if_not_exists: true
  end
end
