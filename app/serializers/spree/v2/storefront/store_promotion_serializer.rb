module Spree
  module V2
    module Storefront
      class StorePromotionSerializer < BaseSerializer
        set_type :store

        attribute :term_and_condition_promotion
      end
    end
  end
end
