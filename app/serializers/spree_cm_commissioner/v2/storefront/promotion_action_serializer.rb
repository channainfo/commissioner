module SpreeCmCommissioner
  module V2
    module Storefront
      class PromotionActionSerializer < BaseSerializer
        attribute :type_name do |action|
          action.class.name.underscore
        end

        has_one :calculator, if: proc { |action| action.respond_to?(:calculator) }
      end
    end
  end
end
