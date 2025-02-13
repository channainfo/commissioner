module Spree
  module Api
    module V2
      module Tenant
        class AccountDeletionsController < BaseController
          before_action :validate_params, only: [:destroy]
          before_action :load_user, only: [:destroy]
          before_action :validate_user, only: [:destroy]

          def destroy
            context = SpreeCmCommissioner::AccountDeletion.call(
              user: @user,
              is_from_backend: false,
              user_deletion_reason_id: params[:user_deletion_reason_id],
              optional_reason: params[:optional_reason]
            )

            return render_error_payload(context.message) unless context.success?

            render json: { message: 'Account deleted successfully' }, status: :ok
          end

          private

          def validate_params
            params.require(:user_deletion_reason_id)
          end

          def load_user
            @user = spree_current_user
          end

          def validate_user
            raise CanCan::AccessDenied unless @user.normal_user?
          end
        end
      end
    end
  end
end
