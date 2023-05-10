module SpreeCmCommissioner
  module V2
    module Storefront
      class PromotionSerializer < BaseSerializer
        attributes :name, :description

        has_many :promotion_rules
        has_many :promotion_actions
      end
    end
  end
end
