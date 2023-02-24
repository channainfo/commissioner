module Spree
  module Admin
    module Merchants
      class UsersController < Spree::Admin::Merchants::BaseController
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
