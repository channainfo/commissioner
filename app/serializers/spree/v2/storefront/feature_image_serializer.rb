module Spree
  module V2
    module Storefront
      class FeatureImageSerializer < BaseSerializer
        set_type :feature_images

        attributes :viewable_type, :viewable_id, :styles
      end
    end
  end
end
