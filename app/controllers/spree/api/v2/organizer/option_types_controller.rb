module Spree
  module Api
    module V2
      module Organizer
        class OptionTypesController < ::Spree::Api::V2::Organizer::BaseController
          def index
            resource = Spree::OptionType.where(kind: 0).all

            render_serialized_payload do
              collection_serializer.new(resource).serializable_hash
            end
          end

          def collection_serializer
            ::Spree::V2::Organizer::OptionTypesSerializer
          end
        end
      end
    end
  end
end
