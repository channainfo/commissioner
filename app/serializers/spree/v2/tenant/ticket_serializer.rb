module Spree
  module V2
    module Tenant
      class TicketSerializer < BaseSerializer
        include ::Spree::Api::V2::DisplayMoneyHelper

        attributes :name

        attribute :purchasable do |ticket|
          value = ticket.purchasable?
          [true, false].include?(value) ? value : nil
        end

        attribute :in_stock do |ticket|
          value = ticket.in_stock?
          [true, false].include?(value) ? value : nil
        end

        attribute :available, &:available?

        attribute :display_price do |ticket, params|
          display_price(ticket, params[:currency])
        end
      end
    end
  end
end
