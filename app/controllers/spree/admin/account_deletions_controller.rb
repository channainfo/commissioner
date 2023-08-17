module Spree
  module Admin
    class AccountDeletionsController < Spree::Admin::ResourceController
      before_action :load_user, only: :destroy

      def destroy
        context = SpreeCmCommissioner::AccountDeletion.call(user: @user, is_from_backend: true)
        flash[:success] = if context.success?
                            'Successfully deleted account'

                          else
                            'Error deleted account'
                          end
        redirect_to spree.admin_users_path
      end

      private

      def load_user
        @user = Spree::User.find(params[:user_id])
      end
    end
  end
end
