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

    def vendor_eligible?(vendor, target_rule_types, user: nil)
      promotable = Spree::Order.new(user: user, item_total: vendor.min_price)
      return false if expired? || usage_limit_exceeded?(promotable) || rules.none?

      # consider eligible? when has rules but not a target type
      specific_rules = rules.select { |rule| target_rule_types.include?(rule.class) }
      return true if specific_rules.none?

      rule_eligibility = specific_rules.index_with { |rule| rule.eligible?(promotable, {}) }
      !!filter_matched_rules(rule_eligibility, specific_rules)
    end

    def filter_matched_rules(rule_eligibility, specific_rules)
      if match_all?
        unless rule_eligibility.values.all?
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end
        specific_rules
      else
        unless rule_eligibility.values.any?
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end

        [rule_eligibility.detect { |_, eligibility| eligibility }.first]
      end
    end

    def date_rule_exists?
      promotion_rules.any? { |rule| rule.respond_to?(:date_eligible?) }
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
