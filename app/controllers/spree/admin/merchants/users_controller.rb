module Spree
  module Admin
    module Merchants
      class UsersController < Spree::Admin::Merchants::BaseController
        def index
          @route = 'Created new route'
        end

        # @overrided
        def model_class
          Spree::User
        end
      end
    end
  end
end
