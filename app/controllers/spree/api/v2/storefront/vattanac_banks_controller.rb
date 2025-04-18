module Spree
  module Api
    module V2
      module Storefront
        class VattanacBanksController < Spree::Api::V2::BaseController
          def create
            result = SpreeCmCommissioner::VattanacBankInitiator.call(params: params)

            if result.success?
              render json: {
                message: 'SUCCESS',
                data: result.data
              }
            else
              render json: {
                message: 'FAILED',
                error: result.error
              }, status: result.status || :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
