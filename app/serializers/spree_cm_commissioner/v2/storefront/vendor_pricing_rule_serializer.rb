module SpreeCmCommissioner
  module V2
    module Storefront
      class VendorPricingRuleSerializer < BaseSerializer
        set_type :pricing_rule

        attributes :date_rule, :length, :active, :free_cancellation, :position, :price_by_dates, :min_price_by_rule, :max_price_by_rule
      end
    end
  end
end
