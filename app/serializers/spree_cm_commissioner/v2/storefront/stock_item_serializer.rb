module SpreeCmCommissioner
  module V2
    module Storefront
      class StockItemSerializer < BaseSerializer
        # add this because some frontend UI need total room/product for user to select.
        # but for this, total stock will publicly shown.
        attributes :count_on_hand
      end
    end
  end
end
