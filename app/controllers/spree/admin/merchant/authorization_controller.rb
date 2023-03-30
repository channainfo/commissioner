module Spree
  module Admin
    module Merchant
      class RoleAuthorizationController < Spree::Admin::Merchant::BaseController
        include Merchant::RoleAuthorization

      end
    end
  end
end