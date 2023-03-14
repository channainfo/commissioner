module SpreeCmCommissioner
  class VendorPriceRulesActivator < BaseInteractor
    delegate :from_date, :to_date, :vendor_id, to: :context

    def call
      load_vendor_listing_prices
      adjust_vendor_listing_prices
    end

    # create listing prices for vendor on specific date
    def load_vendor_listing_prices
      context.vendor_listing_prices = (from_date..to_date).map do |date|
        SpreeCmCommissioner::ListingPrice.first_or_initialize(
          price_source: vendor,
          date: date,
          currency: Spree::Store.default.default_currency
        ) do |vendor_listing_price|
          vendor_listing_price.price = vendor.max_price
        end
      end
    end

    def adjust_vendor_listing_prices
      context.vendor_listing_prices.each do |vendor_listing_price|
        activate_pricing_models_to(vendor_listing_price)
      end
    end

    def activate_pricing_models_to(modelable)
      vendor_price_rules.each do |rule|
        next unless eligible?(rule, modelable)

        rule.pricing_model.activate(adjustable: modelable)
      end
    end

    def eligible?(rule, modelable)
      rule.applicable?(modelable) && rule.eligible?(modelable, {})
    end

    def vendor_price_rules
      context.vendor_price_rules ||= vendor.price_rules
    end

    def vendor
      context.vendor ||= Spree::Vendor.find(vendor_id)
    end
  end
end
