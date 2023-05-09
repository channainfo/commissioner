module SpreeCmCommissioner
  module V2
    module Storefront
      class CalculatorSerializer < BaseSerializer
        attributes :preferences

        attribute :type_name do |rule|
          rule.class.name.underscore
        end
      end
    end
  end
end
