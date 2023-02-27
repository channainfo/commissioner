module Spree
  module Admin
    module Merchant
      class UsersController < Spree::Admin::Merchant::BaseController
        def index
          @search = Spree::User.ransack(params[:q])
          @users = @search.result.page(params[:page] || 1).per(12)
        end

        # @overrided
        def model_class
          Spree::User
        end
      end
    end
  end
end
