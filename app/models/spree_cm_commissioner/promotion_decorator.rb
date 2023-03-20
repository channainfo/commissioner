module SpreeCmCommissioner
  module PromotionDecorator
    def self.prepended(base)
      Rails.application.config.after_initialize do
        const_set(:RULES, Rails.application.config.spree.promotions.rules.select { |r| r.name.start_with?('Spree::Promotion::Rules::') })
        const_set(:ACTIONS, Rails.application.config.spree.promotions.actions.select { |a| a.name.start_with?('Spree::Promotion::Actions::') })
      end

      base.whitelisted_ransackable_attributes = %w[type path promotion_category_id code]
    end
  end
end

unless Spree::Promotion.included_modules.include?(SpreeCmCommissioner::PromotionDecorator)
  Spree::Promotion.prepend(SpreeCmCommissioner::PromotionDecorator)
end
