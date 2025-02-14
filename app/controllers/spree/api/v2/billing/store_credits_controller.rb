module Spree
  module Api
    module V2
      module Billing
        class StoreCreditsController < Spree::Api::V2::BaseController
          def index
            customer = SpreeCmCommissioner::Customer.find_by(id: params[:customer_id])
            @store_credits = customer.user.store_credits
            render json: { store_credits: @store_credits.last.as_json(only: %i[id amount]) }, status: :ok
          end
        end
      end
    end
  end
end
