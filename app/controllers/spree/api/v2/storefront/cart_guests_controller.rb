module Spree
  module Api
    module V2
      module Storefront
        class CartGuestsController < Spree::Api::V2::Storefront::CartController
          # :line_item_id
          def create
            spree_authorize! :update, spree_current_order, order_token

            result = SpreeCmCommissioner::Cart::AddGuest.call(
              order: spree_current_order,
              line_item: line_item,
              guest_params: guest_params
            )

            update_guest(line_item.guests.last) if guest_params[:template_guest_id].present?

            render_order(result)
          end

          # :line_item_id, :guest_id
          def destroy
            spree_authorize! :update, spree_current_order, order_token

            result = SpreeCmCommissioner::Cart::RemoveGuest.call(
              order: spree_current_order,
              line_item: line_item,
              guest_id: params[:guest_id]
            )

            render_order(result)
          end

          private

          def update_guest(guest)
            result = SpreeCmCommissioner::GuestUpdater.call(
              guest: guest,
              guest_params: guest_params,
              template_guest_id: guest_params[:template_guest_id]
            )

            render_error_payload(result.message, 400) unless result.success?
          end

          def guest_params
            @guest_params ||= SpreeCmCommissioner::Cart::GuestParamsBuilderService.new(params).build
          end
        end
      end
    end
  end
end
