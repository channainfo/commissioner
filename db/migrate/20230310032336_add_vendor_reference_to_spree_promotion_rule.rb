class AddVendorReferenceToSpreePromotionRule < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_promotion_rules, :vendor, index: true, if_not_exists: true
    add_foreign_key :spree_promotion_rules, :spree_vendors, column: :vendor_id, if_not_exists: true
  end
end
