module Spree
  module Api
    module V2
      module Billing
        class CustomersController < Spree::Api::V2::BaseController
          def show
            customer = SpreeCmCommissioner::Customer.find_by(id: params[:id])
            if customer.nil?
              render json: { error: 'Customer not found' }, status: :not_found
              return
            end

            place = customer.place.name if customer.place
            render json: {
              customer: customer.as_json(
              only: %i[id email first_name last_name dob gender phone_number
                  ], include: { user: { only: %i[id] }, taxons: { only: %i[id name] } }
              ).merge(place: place)
            }
          end
        end
      end
    end
  end
end
