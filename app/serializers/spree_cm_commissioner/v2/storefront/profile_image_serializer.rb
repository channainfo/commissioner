module SpreeCmCommissioner
  module V2
    module Storefront
      class ProfileImageSerializer < BaseSerializer
        set_type :profile_image

        attributes :viewable_type, :viewable_id, :styles
      end
    end
  end
end
