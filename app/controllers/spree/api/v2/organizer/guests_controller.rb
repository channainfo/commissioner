module Spree
  module Api
    module V2
      module Organizer
        class GuestsController < ::Spree::Api::V2::Organizer::BaseController
          before_action :load_event, only: %i[index]

          def index
            guests = @event.guests.page(params[:page]).per(params[:per_page])

            render_serialized_payload do
              collection_serializer.new(guests).serializable_hash
            end
          end

          def show
            guest = SpreeCmCommissioner::Guest.find(params[:id])
            if guest
              render_serialized_payload { serialize_resource(guest) }
            else
              render_error_payload(guest.errors)
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
              render_serialized_payload { serialize_resource(guest) }
            else
              render_error_payload(guest.errors.full_messages.to_sentence, 400)
            end
          end

          def guest_params
            params.permit(
              :first_name,
              :last_name,
              :dob,
              :gender,
              :occupation_id,
              :nationality_id,
              :other_occupation,
              :social_contact,
              :social_contact_platform,
              :age,
              :emergency_contact,
              :phone_number,
              :address,
              :other_organization,
              :expectation,
              :upload_later
            )
          end

          def load_event
            @event ||= Spree::Taxon.find(params[:event_id])
          end

          def resource_serializer
            ::Spree::V2::Organizer::GuestSerializer
          end

          def collection_serializer
            ::Spree::V2::Organizer::GuestSerializer
          end
        end
      end
    end
  end
end
