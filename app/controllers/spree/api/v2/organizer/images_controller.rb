module Spree
  module Api
    module V2
      module Organizer
        class ImagesController < ::Spree::Api::V2::Organizer::BaseController
          def show
            image = Spree::Image.find(params[:id])
            if image
              render_serialized_payload { serialize_resource(image) }
            else
              render_error_payload(image.errors)
            end
          end

          def create
            context = SpreeCmCommissioner::ImageSaver.call(
              viewable_type: params[:viewable_type],
              viewable_id: params[:viewable_id],
              url: params[:url]
            )
            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          def update
            context = SpreeCmCommissioner::ImageSaver.call(
              id: params[:id],
              url: params[:url]
            )
            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          def destroy
            image = Spree::Image.find_by(id: params[:id])
            if image.destroy
              render_serialized_payload { serialize_resource(image) }
            else
              render_error_payload(image.errors.full_messages.to_sentence, 400)
            end
          end

          def resource_serializer
            ::Spree::V2::Organizer::ImageSerializer
          end
        end
      end
    end
  end
end
