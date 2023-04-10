module Spree
  module Api
    module V2
      module Storefront
        class HomepageDataController < ::Spree::Api::V2::ResourceController
          def show
            render_serialized_payload do
              SpreeCmCommissioner::HomepageDataLoader.with_cache do |home_data_loader|
                serialize_resource(home_data_loader)
              end
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
