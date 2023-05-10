module SpreeCmCommissioner
  module V2
    module Storefront
      class PromotionRuleSerializer < BaseSerializer
        attribute :preferences

        attribute :type_name do |rule|
          rule.class.name.underscore
        end
      end
    end
  end
end
