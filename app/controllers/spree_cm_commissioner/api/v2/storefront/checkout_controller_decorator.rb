module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CheckoutControllerDecorator
          def self.prepended(base)
            base.before_action :require_spree_current_user

            # spree_vpago gem update payment state in #payment_redirect
            # GET /payment_redirect
            base.around_action :set_writing_role, only: %i[payment_redirect]
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::CheckoutController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CheckoutControllerDecorator)
  Spree::Api::V2::Storefront::CheckoutController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CheckoutControllerDecorator)
end
