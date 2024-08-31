module SpreeCmCommissioner
  module Checkout
    module UpdateDecorator
      # override
      def call(order:, params:, permitted_attributes:, request_env:)
        return failure(order) unless order.ensure_line_items_are_in_stock

        super
      end
    end
  end
end

unless Spree::Checkout::Update.included_modules.include?(SpreeCmCommissioner::Checkout::UpdateDecorator)
  Spree::Checkout::Update.prepend(SpreeCmCommissioner::Checkout::UpdateDecorator)
end
