module SpreeCmCommissioner
  module V2
    module Storefront
      class VendorPromotionBannerSerializer < BaseSerializer
        set_type :vendor_promotion_banner

        attributes :viewable_type, :viewable_id, :mobile_styles
      end
    end
  end
end
