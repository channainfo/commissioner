module Spree
  module Api
    module V2
      module Storefront
        class AccountCheckerController < Spree::Api::V2::BaseController
          def index
            checker = SpreeCmCommissioner::ExistingAccountChecker.call(filter_params.to_h)

            Rails.logger.debug filter_params
            if checker.success?
              head :ok
            else
              render_error_payload(checker.message)
            end
          end

          def filter_params
            params.permit(:login, :locale, :format)
          end
        end
      end
    end
  end
end
