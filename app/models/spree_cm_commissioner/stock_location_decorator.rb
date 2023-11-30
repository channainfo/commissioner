module SpreeCmCommissioner
  module StockLocationDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType

      base.has_one  :logo, as: :viewable, class_name: 'SpreeCmCommissioner::VendorLogo', through: :vendor
      base.has_many :nearby_places, -> { order(position: :asc) }, class_name: 'SpreeCmCommissioner::VendorPlace', through: :vendor

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
