module SpreeCmCommissioner
  module V2
    module Storefront
      class HomepageBackgroundSerializer < BaseSerializer
        attributes :title, :segment, :active, :priority

        has_one :app_image, serializer: :asset
        has_one :web_image, serializer: :asset
      end
    end
  end
end
