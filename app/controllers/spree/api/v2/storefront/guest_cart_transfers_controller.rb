module Spree
  module Api
    module V2
      module Storefront
        class GuestCartTransfersController < ::Spree::Api::V2::ResourceController
          def update
            context = SpreeCmCommissioner::GuestCartTransfer.call(guest_cart_params)

            if context.success?
              head :ok
            else
              render json: { error: context.message }, status: :unprocessable_entity
            end
          end

          private

          def guest_cart_params
            {
              store: current_store,
              currency: current_currency,
              guest_token: params[:guest_token],
              guest_id: params[:guest_id],
              user: spree_current_user,
              merge_type: params[:merge_type]
            }
          end
        end
      end
    end
  end
end
