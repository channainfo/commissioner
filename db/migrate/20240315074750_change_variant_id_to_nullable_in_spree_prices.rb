class ChangeVariantIdToNullableInSpreePrices < ActiveRecord::Migration[7.0]
  def change
    # even Spree::Price detace variant from it, and have migrated its data to priceable.
    # variant_id should still be there for reference old data or rollback. variant_id be kept as not required.
    change_column :spree_prices, :variant_id, :integer, null: true
  end
end
