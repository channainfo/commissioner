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

    # calls after initialize inside engine.rb
    def self.set_constants
      promotions = Rails.application.config.spree.promotions

      rules = promotions.rules.select { |r| r.module_parents.include?(SpreeCmCommissioner::PricingModel) }
      actions = promotions.actions.select { |a| a.module_parents.include?(SpreeCmCommissioner::PricingModel) }

      const_set(:RULES, rules)
      const_set(:ACTIONS, actions)
    end
  end
end
