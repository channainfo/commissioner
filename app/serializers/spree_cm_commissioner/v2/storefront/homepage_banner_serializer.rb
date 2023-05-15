module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageBannerSerializer < BaseSerializer
        attributes :title, :redirect_url, :active, :priority

        has_one :app_image, serializer: :homepage_banner_app_image
        has_one :web_image, serializer: :homepage_banner_web_image
      end
    end
  end
end
