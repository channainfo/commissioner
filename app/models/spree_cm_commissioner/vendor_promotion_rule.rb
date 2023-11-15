module SpreeCmCommissioner
  class VendorPromotionRule < Base
    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :promotion_rule, class_name: 'Spree::PromotionRule'
  end
end
