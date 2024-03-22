module SpreeCmCommissioner
  class AppliedPricingModel < Base
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :pricing_model, class_name: 'SpreeCmCommissioner::PricingModel'

    preference :date_unit_options, :hash
  end
end
