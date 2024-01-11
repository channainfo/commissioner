module Spree
  module Api
    module V2
      module Platform
        class HomepageSectionRelatableOptionsController < ResourceController
          def model_class
            return Spree::Vendor if params['model_class'] == 'Spree::Vendor'
            return Spree::Product if params['model_class'] == 'Spree::Product'
            return Spree::Taxon if params['model_class'] == 'Spree::Taxon'

            nil
          end

          def resource_serializer
            ::SpreeCmCommissioner::Api::V2::Platform::HomepageSectionRelatableOptionsSerializer
          end
        end
      end
    end
  end
end
