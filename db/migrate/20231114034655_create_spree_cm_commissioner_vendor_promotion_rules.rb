class CreateSpreeCmCommissionerVendorPromotionRules < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vendor_promotion_rules, if_not_exists: true do |t|
      t.references :vendor
      t.references :promotion_rule

      t.timestamps
    end
  end
end
