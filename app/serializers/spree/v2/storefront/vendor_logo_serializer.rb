module Spree
  module V2
    module Storefront
      class VendorLogoSerializer < BaseSerializer
        set_type :vendor_logo

        attributes :styles
      end
    end
  end
end