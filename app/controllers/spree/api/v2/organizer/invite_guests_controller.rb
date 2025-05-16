module Spree
  module Api
    module V2
      module Organizer
        class InviteGuestsController < ::Spree::Api::V2::Organizer::BaseController
          def show
            @invite_guest = SpreeCmCommissioner::InviteGuest.find_by!(token: params[:id])
            if @invite_guest.present?
              render_serialized_payload { serialize_resource(@invite_guest) }
            else
              render_error_payload(I18n.t('invite.url_not_found'))
            end
          end

          def update
            @invite_guest = SpreeCmCommissioner::InviteGuest.find_by!(id: params[:id])
            @line_item = @invite_guest.order.line_items.first
            @guests = @line_item.guests

            if @invite_guest.claimed_status == 'revoked'
              render json: {error: 'revoked'}

            if @guests.count < @invite_guest.quantity
              guest = @line_item.guests.new(guest_params)

              if guest.save
                if @line_item.guests.count == @invite_guest.quantity
                  @invite_guest.update(claimed_status: :claimed)
                end
                render json: guest
              else
                render_error_payload(guest.errors.full_messages.to_sentence)
              end
            else
              render json: {error: 'fully claimed'}
            end
          end

          private

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
            )
          end

          def resource_serializer
            ::Spree::V2::Organizer::InviteGuestSerializer
          end
        end
      end
    end
  end
end
