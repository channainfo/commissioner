module SpreeCmCommissioner
  module VendorPromotable
    extend ActiveSupport::Concern

    included do
      has_many :vendor_promotion_rules, class_name: 'SpreeCmCommissioner::VendorPromotionRule'
      has_many :promotion_rules, through: :vendor_promotion_rules, class_name: 'Spree::PromotionRule'
      has_many :promotions, through: :promotion_rules, class_name: 'Spree::Promotion'

      has_many :active_promotions, -> { active },
               through: :promotion_rules,
               class_name: 'Spree::Promotion',
               source: :promotion

      has_many :possible_promotions, -> { advertised.active },
               through: :promotion_rules,
               class_name: 'Spree::Promotion',
               source: :promotion

      has_many :auto_apply_promotions, -> { active.where(code: nil, path: nil) },
               through: :promotion_rules,
               class_name: 'Spree::Promotion',
               source: :promotion
    end
  end
end
