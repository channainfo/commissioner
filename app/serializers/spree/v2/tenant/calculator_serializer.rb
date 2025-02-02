module Spree
  module V2
    module Tenant
      class CalculatorSerializer < BaseSerializer
        attributes :preferences

        attribute :type_name do |rule|
          rule.class.name.underscore
        end
      end
    end
  end
end
