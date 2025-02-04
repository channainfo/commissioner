module Spree
  module Api
    module V2
      module Billing
        class SubscriptionsController < ApplicationController
          skip_before_action :verify_authenticity_token

          def index
            customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
            if customer.nil?
              render json: { error: 'Customer not found' }, status: :not_found
              return
            end

            # Fetch all subscriptions for the customer
            subscriptions = SpreeCmCommissioner::Subscription.where(customer_id: customer.id)

            # Format the response
            render json: {
              subscriptions: subscriptions.as_json(
                only: %i[id start_date status quantity],
                include: {
                  variant: { only: %i[id sku],
                             methods: [:price]
                  }
                }
              )
            }, status: :ok
          end

          # def current_user
          #   # Replace this with your actual method to fetch the current user (e.g., from JWT token)
          #   @current_user ||= Spree::User.find_by(id: params[:user_id])
          # end
        end
      end
    end
  end
end
