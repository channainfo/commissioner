module SpreeCmCommissioner
  module AdjustmentDecorator
    def self.prepended(base)
      base.validates :order, presence: true, unless: :adjustable_listing_price?
    end

    def adjustable_listing_price?
      adjustable.is_a?(SpreeCmCommissioner::ListingPrice)
    end
  end
end

# override validation presence of order
Spree::Adjustment.class_eval do
  _validators[:order].find { |v| v.is_a? ActiveRecord::Validations::PresenceValidator }.attributes.delete(:order)
end

unless Spree::Adjustment.included_modules.include?(SpreeCmCommissioner::AdjustmentDecorator)
  Spree::Adjustment.prepend(SpreeCmCommissioner::AdjustmentDecorator)
end
