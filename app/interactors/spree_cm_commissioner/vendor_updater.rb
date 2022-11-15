module SpreeCmCommissioner
  class VendorUpdater < BaseInteractor
    delegate :vendor, to: :context

    def call
      update_min_max_price
    end

    private
    def update_min_max_price
      vendor.update(min_price: min_price, max_price: max_price)
    end

    def min_price
      Spree::Product.min_price(vendor)
    end

    def max_price
      Spree::Product.max_price(vendor)
    end
  end
end