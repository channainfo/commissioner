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

            subscriptions = SpreeCmCommissioner::Subscription.where(customer_id: customer.id)

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

          def create
            Rails.logger.debug 'Starting create action'

            customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
            if customer.nil?
              Rails.logger.debug 'Customer not found'
              render json: { error: 'Customer not found' }, status: :not_found and return
            end

            begin
              subscription = SpreeCmCommissioner::Subscription.new(
                customer: customer,
                variant_id: params[:customer][:variant_id],
                quantity: params[:customer][:quantity],
                start_date: params[:customer][:start_date]
              )
              subscription.save!

              order_result = find_or_create_order(customer)
              render json: { error: order_result[:error] }, status: :unprocessable_entity and return unless order_result[:success]

              render json: { subscription: subscription.as_json }, status: :created and return
            rescue ActiveRecord::RecordInvalid => e
              render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity and return
            rescue StandardError => e
              render json: { error: e.record.errors.full_messages }, status: :internal_server_error and return
            end
          end

          def destroy
            subscription = SpreeCmCommissioner::Subscription.find_by(id: params[:id])
            render json: { error: 'Subscription not found' }, status: :not_found and return if subscription.nil?

            subscription.destroy
            render json: { message: 'Subscription deleted successfully' }, status: :ok
          end

          private

          def find_or_create_order(customer)
            if customer.last_invoice_date.nil?
              result = SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer, today: Time.zone.today)
              return { success: false, error: result.error } if result.failure?
            else
              last_order = customer.orders.last
              from_date = last_order.line_items.first.from_date
              to_date = last_order.line_items.first.to_date

              begin
                last_order.line_items.create!(
                  variant_id: params[:customer][:variant_id],
                  quantity: params[:customer][:quantity],
                  from_date: from_date,
                  to_date: to_date
                )
              rescue ActiveRecord::RecordInvalid => e
                return { success: false, error: e.message }
              end
            end

            { success: true }
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
