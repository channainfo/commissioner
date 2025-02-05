module Spree
  module Api
    module V2
      module Tenant
        class AccountCheckerController < BaseController
          def index
            checker = SpreeCmCommissioner::ExistingAccountChecker.call(filter_params.to_h)

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
