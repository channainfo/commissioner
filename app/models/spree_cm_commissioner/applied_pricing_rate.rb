module SpreeCmCommissioner
  class AppliedPricingRate < Base
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :pricing_rate, class_name: 'SpreeCmCommissioner::PricingRate'

    preference :date_unit_options, :hash
  end
end
