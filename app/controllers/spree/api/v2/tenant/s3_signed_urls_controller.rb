module Spree
  module Api
    module V2
      module Tenant
        class S3SignedUrlsController < BaseController
          def show
            if resource.error_message.blank?
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.error_message)
            end
          end

          def resource
            SpreeCmCommissioner::S3PresignedUrlBuilder.call(
              bucket_name: params[:bucket_name],
              object_key: params[:object_key],
              file_name: params[:file_name]
            )
          end

          def resource_serializer
            Spree::V2::Tenant::S3SignedUrlSerializer
          end
        end
      end
    end
  end
end
