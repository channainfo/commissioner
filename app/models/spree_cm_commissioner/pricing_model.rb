module SpreeCmCommissioner
  class PricingModel < Spree::Promotion
    has_many :rules, autosave: true, foreign_key: :promotion_id, class_name: 'SpreeCmCommissioner::PricingModelRule', dependent: :destroy
    has_many :actions, autosave: true, foreign_key: :promotion_id, class_name: 'SpreeCmCommissioner::PricingModelAction', dependent: :destroy

    def activate(payload)
      payload[:pricing_model] = self

      results = actions.map do |action|
        action.perform(payload)
      end

      results.include?(true)
    end
  end
end
