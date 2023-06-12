module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageBannerSerializer < BaseSerializer
        attributes :title, :redirect_url, :active, :priority

        has_one :app_image, serializer: :asset
        has_one :web_image, serializer: :asset
      end
    end
  end
end
