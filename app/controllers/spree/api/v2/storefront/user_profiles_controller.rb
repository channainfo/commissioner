module Spree
  module Api
    module V2
      module Storefront
        class UserProfilesController < Spree::Api::V2::ResourceController
          before_action :require_spree_current_user
          before_action :required_schema_validation!

          def update
            context = SpreeCmCommissioner::AccountUpdater.call(user: spree_current_user, options: schema.output)

            if context.success?
              head :ok
            else
              render_error_payload(context.message, 422)
            end
          end

          def required_schema_validation!
            return true if required_schema.nil?

            @schema = required_schema.new(request: request, locale: locale, user: spree_current_user)
            return true if schema.success?

            raise SchemaValidationError, schema.error_message
          end

          def required_schema
            SpreeCmCommissioner::UserProfileRequestSchema
          end
        end
      end
    end
  end
end
