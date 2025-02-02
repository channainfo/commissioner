module Spree
  module V2
    module Tenant
      class StateSerializer < BaseSerializer
        attributes :abbr, :name
      end
    end
  end
end
