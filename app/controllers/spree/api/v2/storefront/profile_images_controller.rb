module Spree
  module Api
    module V2
      module Storefront
        class ProfileImagesController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :required_schema_validation!

          def update
            context = SpreeCmCommissioner::ProfileImageUpdater.call(
              user: spree_current_user,
              url: schema.output.fetch(:url)
            )
            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          def required_schema_validation!
            return true if required_schema.nil?

            @schema = required_schema.new(request: request, locale: locale, user: spree_current_user)
            return true if schema.success?

            raise SchemaValidationError, schema.error_message
          end

          def required_schema
            SpreeCmCommissioner::ProfileImageRequestSchema
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::ProfileImageSerializer
          end
        end
      end
    end
  end
end
