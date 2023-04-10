module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageBannerAppImageSerializer < AssetSerializer
        set_type :homepage_banner_app_image

        attributes :viewable_type, :viewable_id, :mobile_styles
      end
    end
  end
end
