module Spree
  module V2
    module Organizer
      class TicketSerializer < BaseSerializer
        attributes :name, :price, :compare_at_price, :available_on, :kyc, :description, :shipping_category_id, :product_type, :status
      end
    end
  end
end
