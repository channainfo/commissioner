module Spree
  module Admin
    module Merchants
      class BaseController < Spree::Admin::ResourceController
        layout 'spree/layouts/merchant'
        helper_method :current_merchant, :user_merchants, :current_user

        def current_user
          @current_user ||= spree_current_user
        end

        def user_merchants
          @user_merchants ||= current_user.vendors
        end

        def current_merchant
          @current_merchant ||= user_merchants.find_by(slug: params[:vendor_id])
        end
      end
    end
  end
end
