module SpreeCmCommissioner
  class CustomerPromotionRule < Base
    belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'
    belongs_to :promotion_rule, class_name: 'Spree::PromotionRule'
  end
end
