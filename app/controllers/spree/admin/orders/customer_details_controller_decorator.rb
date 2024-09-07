module Spree
  module Admin
    module Orders
      module CustomerDetailsControllerDecorator
        # Override
        def load_user
          @user = Spree.user_class.find_by(id: order_params[:user_id]) ||
            (Spree.user_class.find_by(email: order_params[:email]) if order_params[:email].present?) ||
            (Spree.user_class.find_by(phone_number: order_params[:phone_number]) if order_params[:phone_number].present?)

          return if @user

          flash.now[:error] = Spree.t(:user_not_found)
          render action: :edit, status: :unprocessable_entity
        end

        def order_params
          params.require(:order).permit(
            :email, :user_id, :use_billing, :phone_number,
            bill_address_attributes: permitted_address_attributes,
            ship_address_attributes: permitted_address_attributes
          )
        end
      end
    end
  end
end

Spree::Admin::Orders::CustomerDetailsController.prepend(Spree::Admin::Orders::CustomerDetailsControllerDecorator)
