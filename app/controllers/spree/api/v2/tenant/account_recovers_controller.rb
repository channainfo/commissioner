module Spree
  module Api
    module V2
      module Tenant
        class AccountRecoversController < BaseController
          def update
            context = SpreeCmCommissioner::AccountRecover.call(**filter_params.slice(:id_token, :login, :password))
            if context.success?
              render json: { message: 'Account Recovered successfully' }, status: :ok
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
