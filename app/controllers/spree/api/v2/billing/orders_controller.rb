module Spree
  module Api
    module V2
      module Billing
        class OrdersController < Spree::Api::V2::BaseController
          def index
            customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
            orders = customer.orders
            render json: { orders: orders.as_json(
              only: %i[id payment_state completed_at total subscription_id], include: { invoice: { only: :invoice_number } }
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

          def complete
            order = Spree::Order.find(params[:id])
            if order.payment_state == 'balance_due'
              order.update(payment_state: 'paid')
              render json: { message: 'Order completed successfully', order: order.as_json(only: %i[id payment_state]) }, status: :ok
            else
              render json: { error: 'Order cannot be completed' }, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
