module SpreeCmCommissioner
  class VendorUpdater < BaseInteractor
    delegate :vendor, to: :context

    def call
      vendor.update_min_max_price
      vendor.update_total_inventory
    end
  end
end