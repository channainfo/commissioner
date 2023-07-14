module Spree
  module Api
    module V2
      module Storefront
        class HomepageDataController < ::Spree::Api::V2::ResourceController
          def show
            home_data_loader = SpreeCmCommissioner::HomepageDataLoader.with_cache

            render_serialized_payload do
              serialize_resource(home_data_loader)
            end
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::HomepageDataSerializer
          end
        end
      end
    end
  end
end
