module Spree
  module Api
    module V2
      module Storefront
        class S3SignedUrlsController < ::Spree::Api::V2::ResourceController
          def show
            if resource.error_message.blank?
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.error_message)
            end
          end

          def resource
            SpreeCmCommissioner::S3SignedUrl.new(params[:file_name])
          end

          def resource_serializer
            Spree::V2::Storefront::S3SignedUrlSerializer
          end
        end
      end
    end
  end
end
