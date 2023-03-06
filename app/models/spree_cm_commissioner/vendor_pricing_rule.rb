require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class VendorPricingRule < ApplicationRecord
    acts_as_list scope: :vendor

    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy

    attr_accessor :price_by_dates, :min_price_by_rule, :max_price_by_rule

    def matching_rules(day)
      start_rule_date = date_rule['value'].to_date
      end_rule_date = start_rule_date + length - 1

      date_rule['type'] == 'fixed_date' && day.between?(start_rule_date, end_rule_date)
    end
  end
end
