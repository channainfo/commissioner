module SpreeCmCommissioner
  module StockLocationDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType

      base.after_commit :update_vendor_location

      base.after_save :setup_nearby_place, if: :saved_change_to_lat?
      base.after_save :setup_nearby_place, if: :saved_change_to_lon?

      def update_vendor_location
        vendor&.update_location
      end

      def setup_nearby_place
        return if lat.to_f.zero?
        return if lon.to_f.zero?

        SpreeCmCommissioner::NearbyPlacesLoaderJob.perform_later(vendor_id)
      end
    end
  end
end

unless Spree::StockLocation.included_modules.include?(SpreeCmCommissioner::StockLocationDecorator)
  Spree::StockLocation.prepend(SpreeCmCommissioner::StockLocationDecorator)
end
