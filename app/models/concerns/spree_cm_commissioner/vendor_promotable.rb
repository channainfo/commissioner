module SpreeCmCommissioner
  module VendorPromotable
    extend ActiveSupport::Concern

    included do
      has_many :promotion_rules, class_name: 'Spree::PromotionRule'
      has_many :promotions, through: :promotion_rules, class_name: 'Spree::Promotion'

      has_many :active_promotions, -> { active },
               through: :promotion_rules,
               class_name: 'Spree::Promotion',
               source: :promotion

      has_many :possible_promotions, -> { advertised.active },
               through: :promotion_rules,
               class_name: 'Spree::Promotion',
               source: :promotion
    end
  end
end
