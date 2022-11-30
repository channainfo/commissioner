module Spree
  module Api
    module V2
      module Storefront
        class AccountCheckersController < Spree::Api::V2::BaseController
          def show
            checker = SpreeCmCommissioner::AccountChecker.call(filter_params.to_h)
            if checker.success?
              head :ok
            else
              render_error_payload(checker.message)
            end
          end

          def filter_params
            params.permit(:login, :id_token)
          end
        end
      end
    end
  end
end
