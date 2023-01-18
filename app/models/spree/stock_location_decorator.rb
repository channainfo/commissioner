module Spree
  module StockLocationDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType

      base.after_commit :update_vendor_location

      def update_vendor_location
        vendor&.update_location
      end
    end

  end
end

Spree::StockLocation.prepend(Spree::StockLocationDecorator)
