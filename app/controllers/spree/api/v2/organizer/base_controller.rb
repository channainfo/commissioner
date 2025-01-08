module Spree
  module Api
    module V2
      module Organizer
        class BaseController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def render_serialized_payload(status = 200)
            render json: yield, status: status, content_type: content_type
          end
        end
      end
    end
  end
end
