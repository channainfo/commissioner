module Spree
  module Api
    module V2
      module ResourceControllerDecorator
        def self.prepended(base)
          base.before_action :required_schema_validation!
          base.rescue_from SpreeCmCommissioner::SchemaValidationError, with: :rescue_schema_validation_error
        end

        def app_version
          request.headers['Cm-App-Version']
        end

        def app_name
          request.headers['Cm-App-Name']
        end

        def required_schema_validation!
          return true if required_schema.nil?

          schema = required_schema.new(request: request)
          return true if schema.success?

          raise SpreeCmCommissioner::SchemaValidationError, schema.error_message
        end

        def required_schema
          nil
        end

        def rescue_schema_validation_error(exc)
          render_error_payload(exc.message, 422)
        end
      end
    end
  end
end

Spree::Api::V2::ResourceController.prepend(Spree::Api::V2::ResourceControllerDecorator)
