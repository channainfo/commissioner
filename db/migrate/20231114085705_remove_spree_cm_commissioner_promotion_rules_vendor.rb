class RemoveSpreeCmCommissionerPromotionRulesVendor < ActiveRecord::Migration[7.0]
  def change
    Spree::PromotionRule.where(type: "SpreeCmCommissioner::Promotion::Rules::Vendor").each do |rule|
      vendor = rule.vendor
      rule.update(type: "SpreeCmCommissioner::Promotion::Rules::Vendors", vendor: nil)

      SpreeCmCommissioner::VendorPromotionRule.create(vendor: vendor, promotion_rule: rule)
    end
  end
end
