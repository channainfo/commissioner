module Spree
  module Api
    module V2
      module Tenant
        class AccountRecoversController < BaseController
          def update
            context = SpreeCmCommissioner::AccountRecover.call(**filter_params.slice(:id_token, :login, :password, :tenant_id))
            if context.success?
              render json: { message: 'Account Recovered successfully' }, status: :ok
            else
              render_error_payload(context.message)
            end
          end

          private

          def filter_params
            params.permit(:id_token, :login, :password).merge(tenant_id: MultiTenant.current_tenant_id)
          end
        end
      end
    end
  end
end
