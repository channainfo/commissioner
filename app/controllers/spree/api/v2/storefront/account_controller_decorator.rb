module Spree
  module Api
    module V2
      module Storefront
        module AccountControllerDecorator
          def self.prepended(_base)
            private

            def resource_serializer
              return Spree::V2::Storefront::GuestUserSerializer if resource.guest?

              super
            end
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::AccountController.included_modules.include?(Spree::Api::V2::Storefront::AccountControllerDecorator)
  Spree::Api::V2::Storefront::AccountController.prepend(Spree::Api::V2::Storefront::AccountControllerDecorator)
end
