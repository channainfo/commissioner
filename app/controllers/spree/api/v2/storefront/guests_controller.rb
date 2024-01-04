module Spree
  module Api
    module V2
      module Storefront
        class GuestsController < ::Spree::Api::V2::ResourceController
          # override
          def model_class
            SpreeCmCommissioner::Guest
          end

          # override
          def collection
            model_class.all
          end

          # override
          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::GuestSerializer
          end

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::GuestSerializer
          end

          # override
          def show
            guest = SpreeCmCommissioner::Guest.find(params[:id])

            render_serialized_payload { serialize_resource(guest) }
          end

          def create
            context = SpreeCmCommissioner::Guest.create(guest_params)

            if context.save
              render_serialized_payload(201) { serialize_resource(context) }
            else
              render_error_payload(context, 400)
            end
          end

          def update
            guest = SpreeCmCommissioner::Guest.find(params[:id])

            if guest.update(guest_params)
              render_serialized_payload { serialize_resource(guest) }
            else
              render_error_payload(guest, 400)
            end
          end

          def destroy
            guest = SpreeCmCommissioner::Guest.find(params[:id])

            if guest.destroy
              render_serialized_payload(204) { serialize_resource(guest) }
            else
              render_error_payload(guest, 400)
            end
          end

          private

          def guest_params
            params.permit(
              :first_name, :last_name, :dob, :gender, :occupation_id, :line_item_id
            )
          end
        end
      end
    end
  end
end
