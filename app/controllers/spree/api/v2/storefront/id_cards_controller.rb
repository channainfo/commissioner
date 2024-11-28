module Spree
  module Api
    module V2
      module Storefront
        class IdCardsController < ::Spree::Api::V2::ResourceController
          def create
            context = SpreeCmCommissioner::GuestIdCardManager.call(
              card_type: id_card_params[:card_type],
              front_image_url: id_card_params[:front_image_url],
              back_image_url: id_card_params[:back_image_url],
              guest_id: id_card_params[:guest_id]
            )

            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          def update
            context = SpreeCmCommissioner::GuestIdCardManager.call(
              card_type: id_card_params[:card_type],
              front_image_url: id_card_params[:front_image_url],
              back_image_url: id_card_params[:back_image_url],
              guest_id: id_card_params[:guest_id]
            )

            if context.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context.message)
            end
          end

          def destroy
            id_card = SpreeCmCommissioner::IdCard.find(params[:id])

            if id_card.destroy
              render_serialized_payload(204) { serialize_resource(id_card) }
            else
              render_error_payload(id_card, 400)
            end
          end

          private

          def id_card_params
            params.permit(:card_type, :front_image_url, :back_image_url, :guest_id)
          end

          def model_class
            SpreeCmCommissioner::IdCard
          end

          def resource_serializer
            Spree::V2::Storefront::IdCardSerializer
          end
        end
      end
    end
  end
end
