module Spree
  module Api
    module V2
      module Storefront
        class AccountRecoversController < Spree::Api::V2::BaseController
          def update
            context = SpreeCmCommissioner::AccountRecover.call(**filter_params.slice(:id_token, :login, :password))
            if context.success?
              head :ok
            else
              render_error_payload(context.message)
            end
          end

          private

          def filter_params
            params.permit(:id_token, :login, :password)
          end
        end
      end
    end
  end
end
