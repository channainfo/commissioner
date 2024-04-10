module SpreeCmCommissioner
  module LineItemPricingsConcern
    extend ActiveSupport::Concern

    included do
      has_many :applied_pricing_rates, class_name: 'SpreeCmCommissioner::AppliedPricingRate', dependent: :destroy
      has_many :applied_pricing_models, class_name: 'SpreeCmCommissioner::AppliedPricingModel', dependent: :destroy

      validates :pricing_models_amount, allow_nil: true, numericality: true
      with_options allow_nil: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: Spree::Price::MAXIMUM_AMOUNT } do
        validates :pricing_rates_amount
        validates :pricing_subtotal
      end

      money_methods :pricing_rates_amount, :pricing_models_amount, :pricing_subtotal
    end
  end
end
