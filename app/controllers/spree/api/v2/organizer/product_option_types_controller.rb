module Spree
  module Api
    module V2
      module Organizer
        class ProductOptionTypesController < ::Spree::Api::V2::Organizer::BaseController
          def create
            option_type_ids = Array(params[:option_type_ids])
            created_resources = []
            errors = []

            option_type_ids.each do |option_type_id|
              resource = Spree::ProductOptionType.new(product_id: params[:product_id], option_type_id: option_type_id)

              if resource.save
                created_resources << resource
              else
                errors << resource.errors.full_messages.to_sentence
              end
            end

            if errors.any?
              render_error_payload(errors.join(', '), 400)
            else
              render_serialized_payload(201) { serialize_resource(created_resources) }
            end
          end

          private

          def resource_serializer
            ::Spree::V2::Organizer::ProductOptionTypesSerializer
          end
        end
      end
    end
  end
end
