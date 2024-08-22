module Spree
  module Admin
    class UserPaymentOptionsController < Spree::Admin::ResourceController
      before_action :payment_method

      def collection
        @collection ||= payment_method.user_payment_options.page(params[:page])&.per(params[:per_page])
      end

      def new
        @available_users ||= Spree::User.where.not(id: payment_method.user_payment_options.pluck(:user_id))
      end

      def create
        user_payment_option = SpreeCmCommissioner::UserPaymentOption.new(permitted_resource_params)

        if user_payment_option.save
          flash[:success] = flash_message_for(user_payment_option, :successfully_created)
        else
          flash[:error] = user_payment_option.errors.full_messages.join(', ')
        end
        redirect_to collection_url
      end

      private

      def payment_method
        @payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
      end

      def model_class
        SpreeCmCommissioner::UserPaymentOption
      end

      def object_name
        'spree_cm_commissioner_user_payment_option'
      end

      def collection_url
        admin_payment_method_user_payment_options_path
      end

      def permitted_resource_params
        params.require(object_name).permit(:payment_method_id, :user_id)
      end
    end
  end
end
