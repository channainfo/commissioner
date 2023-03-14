module SpreeCmCommissioner
  class PricingModelAction < Spree::PromotionAction
    belongs_to :pricing_model, class_name: 'SpreeCmCommissioner::PricingModel', foreign_key: :promotion_id, dependent: :destroy
  end
end
