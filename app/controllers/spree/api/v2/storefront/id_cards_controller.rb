module Spree
  module Api
    module V2
      module Storefront
        class IdCardsController < ::Spree::Api::V2::ResourceController
          def create
            context = id_card_manager_context

            if context&.success?
              render_serialized_payload { serialize_resource(context.result) }
            else
              render_error_payload(context&.message || 'Failed to create ID card')
            end
          end

          def update
            context = id_card_manager_context

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
            params.permit(:card_type, :front_image_url, :back_image_url, :guest_id, :template_guest_id)
          end

          def id_card_manager_context
            options = {
              card_type: id_card_params[:card_type],
              front_image_url: id_card_params[:front_image_url],
              back_image_url: id_card_params[:back_image_url]
            }
            if id_card_params[:guest_id].present?
              id_card_options = options.merge(guestable_id: id_card_params[:guest_id])
              SpreeCmCommissioner::GuestIdCardManager.call(**id_card_options)
            elsif id_card_params[:template_guest_id].present?
              id_card_options = options.merge(guestable_id: id_card_params[:template_guest_id])
              SpreeCmCommissioner::TemplateGuestIdCardManager.call(**id_card_options)
            end
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
