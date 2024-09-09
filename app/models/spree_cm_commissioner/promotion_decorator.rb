module SpreeCmCommissioner
  module PromotionDecorator
    def self.prepended(base)
      base.attr_accessor :auto_apply
      base.before_validation :setup_auto_apply_promotion, if: :auto_apply?

      base.has_one :store_promotion, class_name: 'Spree::StorePromotion'
      base.has_one :default_store, through: :store_promotion, source: :store, class_name: 'Spree::Store'
    end

    def setup_auto_apply_promotion
      self.code = nil
      self.path = nil
    end

    def auto_apply?
      auto_apply.in?([true, 'true', '1'])
    end

    def date_eligible?(date)
      rules = promotion_rules.select { |rule| rule.respond_to?(:date_eligible?) }

      if match_all?
        rules.all? { |rule| rule.date_eligible?(date) }
      else
        rules.any? { |rule| rule.date_eligible?(date) }
      end
    end

    def guest_eligible?(guest, line_item)
      rules = promotion_rules.select { |rule| rule.respond_to?(:guest_eligible?) }
      if match_all?
        rules.all? { |rule| rule.guest_eligible?(guest, line_item) }
      else
        rules.any? { |rule| rule.guest_eligible?(guest, line_item) }
      end
    end
  end
end

unless Spree::Promotion.included_modules.include?(SpreeCmCommissioner::PromotionDecorator)
  Spree::Promotion.prepend(SpreeCmCommissioner::PromotionDecorator)
end
