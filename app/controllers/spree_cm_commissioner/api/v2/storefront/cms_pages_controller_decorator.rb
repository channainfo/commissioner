module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module CmsPagesControllerDecorator
          def scope
            super.by_locale(I18n.locale).where(tenant_id: nil)
          end
        end
      end
    end
  end
end

# Prepend the decorator to the CmsPagesController
unless Spree::Api::V2::Storefront::CmsPagesController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::CmsPagesControllerDecorator)
  Spree::Api::V2::Storefront::CmsPagesController.prepend(SpreeCmCommissioner::Api::V2::Storefront::CmsPagesControllerDecorator)
end
