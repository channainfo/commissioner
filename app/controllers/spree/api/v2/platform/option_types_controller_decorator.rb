module Spree
  module Api
    module V2
      module Platform
        module OptionTypesControllerDecorator
          def self.prepended(base)
            def collection
              @collection ||= scope.where(kind: params[:kind]).ransack(params[:filter]).result
            end
          end
        end
      end
    end
  end
end

Spree::Api::V2::Platform::OptionTypesController.prepend Spree::Api::V2::Platform::OptionTypesControllerDecorator