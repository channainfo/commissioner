module SpreeCmCommissioner
  module PromotionDecorator
    def self.prepended(base)
      base.whitelisted_ransackable_attributes = %w[type path promotion_category_id code]

      def base.set_constants
        promotions = Rails.application.config.spree.promotions

        rules = promotions.rules.select { |r| r.module_parents.include?(Spree::Promotion) }
        actions = promotions.actions.select { |a| a.module_parents.include?(Spree::Promotion) }

        const_set(:RULES, rules)
        const_set(:ACTIONS, actions)
      end
    end
  end
end

unless Spree::Promotion.included_modules.include?(SpreeCmCommissioner::PromotionDecorator)
  Spree::Promotion.prepend(SpreeCmCommissioner::PromotionDecorator)
end
