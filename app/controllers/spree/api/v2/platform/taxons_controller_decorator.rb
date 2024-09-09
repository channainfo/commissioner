module Spree
  module Api
    module V2
      module Platform
        module TaxonsControllerDecorator
          def collection
            @collection ||= super.ransack(params[:q]).result
          end
        end
      end
    end
  end
end

Spree::Api::V2::Platform::TaxonsController.prepend Spree::Api::V2::Platform::TaxonsControllerDecorator
