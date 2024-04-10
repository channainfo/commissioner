module SpreeCmCommissioner
  class AppliedPricingModel < Base
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :pricing_model, class_name: 'SpreeCmCommissioner::PricingModel'
    belongs_to :pricing_rate, class_name: 'SpreeCmCommissioner::PricingRate', optional: true

    extend ::Spree::DisplayMoney
    money_methods :amount

    delegate :currency, to: :line_item
  end
end
