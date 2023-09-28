module Spree
  module V2
    module Storefront
      class LineItemOrderSerializer < BaseSerializer
        set_type :order

        attributes :number, :state
      end
    end
  end
end
