module Spree
  module V2
    module Tenant
      class VendorImageSerializer < BaseSerializer
        set_type :vendor_image

        attributes :styles
      end
    end
  end
end
