module SpreeCmCommissioner
  module V2
    module Storefront
      class PromotionRuleSerializer < BaseSerializer
        attribute :preferences

        attributes :user_ids do |rule|
          rule.user_ids if rule.respond_to?(:user_ids)
        end

        attribute :type_name do |rule|
          rule.class.name.underscore
        end
      end
    end
  end
end
