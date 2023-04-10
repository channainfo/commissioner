module SpreeCmCommissioner
  module V2
    module Storefront
      class VendorAppPromotionBannerSerializer < BaseSerializer
        set_type :vendor_app_promotion_banner

        attributes :viewable_type, :viewable_id, :mobile_styles
      end
    end
  end
end
