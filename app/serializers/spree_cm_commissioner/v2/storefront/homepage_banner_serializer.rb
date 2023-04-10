module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageBannerSerializer < BaseSerializer
        set_type   :homepage_banner

        attributes :title, :redirect_url, :active, :priority

        has_one :app_image, serializer: :homepage_banner_app_image
      end
    end
  end
end
