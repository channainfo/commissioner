# Following decoration will detach price from variant. Allow price to belong to priceable instead.
module SpreeCmCommissioner
  module PriceDecorator
    def self.prepended(base)
      base.belongs_to :priceable, polymorphic: true, inverse_of: :prices, touch: true, optional: false

      # priceable must have tax_category
      base.delegate :tax_category, to: :priceable
    end

    # override
    def price_including_vat_for(price_options)
      options = price_options.merge(tax_category: tax_category)
      gross_amount(price, options)
    end

    # override
    def compare_at_price_including_vat_for(price_options)
      options = price_options.merge(tax_category: tax_category)
      gross_amount(compare_at_price, options)
    end
  end
end

Spree::Price.prepend(SpreeCmCommissioner::PriceDecorator) unless Spree::Price.included_modules.include?(SpreeCmCommissioner::PriceDecorator)
