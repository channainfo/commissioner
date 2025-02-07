module Spree
  module Api
    module V2
      module Billing
        class OrdersController < Spree::Api::V2::BaseController
          def index
            customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
            subscriptions = SpreeCmCommissioner::Subscription.where(customer_id: customer.id)
            orders = subscriptions.map(&:orders).flatten
            render json: { orders: orders.as_json(
              only: %i[id payment_state completed_at total], include: { invoice: { only: :invoice_number } }
            )
            }, status: :ok
          end

          def show
            order = Spree::Order.find(params[:id])
            render json: { order: order.as_json(
              only: %i[id total], include: {
                line_items: { only: %i[quantity price], include: { variant: { only: :sku } } },
                adjustments: { only: %i[amount label] }
              }
            )
            }, status: :ok
          end
        end
      end
    end
  end
end
