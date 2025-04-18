module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CheckoutControllerDecorator
          def self.prepended(base)
            base.include SpreeCmCommissioner::OrderConcern
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::CheckoutController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CheckoutControllerDecorator)
  Spree::Api::V2::Storefront::CheckoutController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CheckoutControllerDecorator)
end
