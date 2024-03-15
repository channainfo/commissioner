# Following decoration will detach price from variant. Allow price to belong to priceable instead.
module SpreeCmCommissioner
  module PriceDecorator
    def self.prepended(base)
      base.belongs_to :priceable, polymorphic: true, inverse_of: :prices, touch: true, optional: false
    end
  end
end

Spree::Price.prepend(SpreeCmCommissioner::PriceDecorator) unless Spree::Price.included_modules.include?(SpreeCmCommissioner::PriceDecorator)
