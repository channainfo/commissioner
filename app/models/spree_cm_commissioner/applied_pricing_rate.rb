module SpreeCmCommissioner
  class AppliedPricingRate < Base
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :pricing_rate, class_name: 'SpreeCmCommissioner::PricingRate'

    delegate :currency, to: :line_item

    extend ::Spree::DisplayMoney
    money_methods :amount

    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: Spree::Price::MAXIMUM_AMOUNT }
  end
end
