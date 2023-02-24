module Spree
  module Admin
    module Merchants
      class BaseController < Spree::Admin::ResourceController
        layout 'spree/layouts/merchant'
      end
    end
  end
end
