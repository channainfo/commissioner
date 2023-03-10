module Spree
  module Admin
    module Merchant
      class UsersController < Spree::Admin::Merchant::BaseController
        def index
          @search = Spree::User.ransack(params[:q])
          @users = @search.result.page(page).per(per_page)
        end

        # @overrided
        def model_class
          Spree::User
        end

        def object_name
          'user'
        end
      end
    end
  end
end
