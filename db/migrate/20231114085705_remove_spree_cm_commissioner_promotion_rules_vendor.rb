class RemoveSpreeCmCommissionerPromotionRulesVendor < ActiveRecord::Migration[7.0]
  def change
    Spree::PromotionRule.where(type: "SpreeCmCommissioner::Promotion::Rules::Vendor").update_all(type: "SpreeCmCommissioner::Promotion::Rules::Vendors")
    Spree::PromotionRule.where(type: "SpreeCmCommissioner::Promotion::Rules::Vendor", vendor_id: nil).delete_all
    Spree::PromotionRule.where(type: "SpreeCmCommissioner::Promotion::Rules::Vendors").where.not(vendor_id: nil).each do |rule|
      SpreeCmCommissioner::VendorPromotionRule.create(vendor_id: rule.vendor_id, promotion_rule: rule)
      rule.update_column(:vendor_id, nil)
    end
  end
end

