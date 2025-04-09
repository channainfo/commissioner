module Spree
  module V2
    module Tenant
      class StockLocationSerializer < BaseSerializer
        set_type :stock_location

        attributes :name
      end
    end
  end
end
