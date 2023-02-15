module SpreeCmCommissioner
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

unless Spree::StockLocation.included_modules.include?(SpreeCmCommissioner::StockLocationDecorator)
  Spree::StockLocation.prepend(SpreeCmCommissioner::StockLocationDecorator)
end
