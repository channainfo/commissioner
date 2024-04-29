# Following decoration will detach price from variant. Allow price to belong to priceable instead.
module SpreeCmCommissioner
  module PriceDecorator
    def self.prepended(base)
      base.belongs_to :priceable, polymorphic: true, inverse_of: :prices, touch: true, optional: false
    end

    def tax_category
      priceable.respond_to?(:tax_category) ? priceable.tax_category : nil
    end

    # override:
    # to get tax_category from priceable instead of variant
    def price_including_vat_for(price_options)
      options = price_options.merge(tax_category: tax_category)
      gross_amount(price, options)
    end

    # override:
    # to get tax_category from priceable instead of variant
    def compare_at_price_including_vat_for(price_options)
      options = price_options.merge(tax_category: tax_category)
      gross_amount(compare_at_price, options)
    end
  end
end

Spree::Price.prepend(SpreeCmCommissioner::PriceDecorator) unless Spree::Price.included_modules.include?(SpreeCmCommissioner::PriceDecorator)
