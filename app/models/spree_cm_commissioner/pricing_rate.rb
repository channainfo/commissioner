module SpreeCmCommissioner
  class PricingRate < Base
    include Priceable
    include PricingRuleable

    belongs_to :pricing_rateable, optional: false, polymorphic: true, inverse_of: :pricing_rates
    has_many :applied_pricing_rates, class_name: 'SpreeCmCommissioner::AppliedPricingRate', dependent: :restrict_with_error

    has_one :default_price,
            -> { where(currency: Spree::Store.default.default_currency) },
            class_name: 'Spree::Price',
            as: :priceable

    delegate :display_price, :display_amount, :price, :currency, :price=,
             :price_including_vat_for, :currency=, :display_compare_at_price,
             :compare_at_price, :compare_at_price=, to: :find_or_build_default_price

    after_save -> { default_price.save }, if: -> { default_price.present? && (default_price.changed? || default_price.new_record?) }

    def find_or_build_default_price
      default_price || build_default_price
    end

    # spree_price required tax category for gross_amount calculation
    def tax_category
      pricing_rateable.respond_to?(:tax_category) ? pricing_rateable.tax_category : nil
    end
  end
end
