module SpreeCmCommissioner
  module PromotionDecorator
    def self.prepended(base)
      base.attr_accessor :auto_apply

      base.before_validation :setup_auto_apply_promotion, if: :auto_apply?
    end

    def setup_auto_apply_promotion
      self.code = nil
      self.path = nil
    end

    def auto_apply?
      auto_apply.in?([true, 'true', '1'])
    end

    def date_eligible?(date)
      promotion_rules.any? do |rule|
        rule.respond_to?(:date_eligible?) && rule.date_eligible?(date)
      end
    end
  end
end

unless Spree::Promotion.included_modules.include?(SpreeCmCommissioner::PromotionDecorator)
  Spree::Promotion.prepend(SpreeCmCommissioner::PromotionDecorator)
end
