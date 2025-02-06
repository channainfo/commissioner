module Spree
  module Api
    module V2
      module Billing
        class PlacesController < Spree::Api::V2::BaseController
          def index
            @places = SpreeCmCommissioner::Place.all
            render json: { places: @places.as_json(only: %i[id name]) }, status: :ok
          end
        end
      end
    end
  end
end
