# Module for pricing model & rate. It's expected to have following columns:
# :match_policy, :effective_from, :effective_to, :priority
module SpreeCmCommissioner
  module PricingRuleable
    extend ActiveSupport::Concern

    included do
      acts_as_list column: :priority

      has_many :pricing_rules, as: :pricing_ruleable, class_name: 'SpreeCmCommissioner::PricingRule', dependent: :destroy

      enum match_policy: %i[all any none].freeze, _prefix: true

      default_scope { order(:priority) }

      scope :active, lambda {
        where('effective_from IS NULL OR effective_from < ?', Time.current)
          .where('effective_to IS NULL OR effective_to > ?', Time.current)
      }
    end

    def eligible?(options)
      applicable_rules = pricing_rules.select { |rule| rule.applicable?(options) }
      return false if applicable_rules.none?

      if match_policy_all?
        applicable_rules.all? { |rule| rule.eligible?(options) }
      elsif match_policy_any?
        applicable_rules.any? { |rule| rule.eligible?(options) }
      elsif match_policy_none?
        applicable_rules.none? { |rule| rule.eligible?(options) }
      end
    end

    # available only rules that not created.
    def available_pricing_rules
      existing_rules = pricing_rules.map { |rule| rule.class.name }
      default_pricing_rules.reject { |r| existing_rules.include? r }
    end

    def default_pricing_rules
      if product_type == 'accommodation'
        [
          'SpreeCmCommissioner::PricingRules::CustomDates',
          'SpreeCmCommissioner::PricingRules::EarlyBird',
          'SpreeCmCommissioner::PricingRules::ExtraAdults',
          'SpreeCmCommissioner::PricingRules::ExtraKids',
          'SpreeCmCommissioner::PricingRules::GroupBooking',
          'SpreeCmCommissioner::PricingRules::Weekend'
        ]
      else
        [
          'SpreeCmCommissioner::PricingRules::EarlyBird',
          'SpreeCmCommissioner::PricingRules::GroupBooking'
        ]
      end
    end
  end
end
