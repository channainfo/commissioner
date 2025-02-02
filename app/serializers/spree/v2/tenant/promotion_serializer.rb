module Spree
  module V2
    module Tenant
      class PromotionSerializer < BaseSerializer
        attributes :name, :description, :match_policy, :advertise, :expires_at

        has_many :promotion_rules
        has_many :promotion_actions
      end
    end
  end
end
