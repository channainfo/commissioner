module SpreeCmCommissioner
  class PricingModelRule < Spree::PromotionRule
    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy
    belongs_to :pricing_model, class_name: 'SpreeCmCommissioner::PricingModel', foreign_key: :promotion_id, dependent: :destroy
  end
end
