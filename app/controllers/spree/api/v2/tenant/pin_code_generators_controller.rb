module Spree
  module Api
    module V2
      module Tenant
        class PinCodeGeneratorsController < BaseController
          # :phone_number, :email, :type
          def create
            context = SpreeCmCommissioner::PinCodeGenerator.call(pin_code_attrs)

            if context.success?
              render_serialized_payload(201) { serialize_resource(context.pin_code) }
            else
              render_error_payload(context.message, 400)
            end
          end

          def serialize_resource(resource)
            resource_serializer.new(
              resource
            ).serializable_hash
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::PinCodeSerializer
          end

          def pin_code_attrs
            params.slice(:phone_number, :email, :type)
          end
        end
      end
    end
  end
end
