module Spree
  module Api
    module V2
      module Organizer
        class InviteGuestsController < ::Spree::Api::V2::Organizer::BaseController
          before_action :load_invite_guest_by_token, only: :show
          before_action :load_invite_guest, :assign_line_item_data, only: :update

          def show
            render_serialized_payload { serialize_resource(@invite_guest) }
          end

          def update
            return render_error(:revoked) if revoked?
            return render_error(:closed) if expired?
            return render_error(:fully_claimed) if fully_claimed?

            guest = @line_item.guests.new(guest_params)

            if guest.save
              @invite_guest.update(claimed_status: :claimed) if @line_item.guests.count == @invite_guest.quantity
              guest.reload
              render json: SpreeCmCommissioner::V2::Storefront::GuestSerializer.new(guest).serializable_hash
            else
              render_error_payload(guest.errors.full_messages.to_sentence)
            end
          end

          private

          def load_invite_guest_by_token
            @invite_guest = SpreeCmCommissioner::InviteGuest.find_by(token: params[:id])
          rescue ActiveRecord::RecordNotFound
            render_error_payload(I18n.t('invite.url_not_found'))
          end

          def load_invite_guest
            @invite_guest = SpreeCmCommissioner::InviteGuest.find(params[:id])
          end

          def assign_line_item_data
            @line_item = @invite_guest.order.line_items.first
            @guests = @line_item.guests
          end

          def revoked?
            @invite_guest.claimed_status == 'revoked'
          end

          def expired?
            @invite_guest.expiration_date < Time.current
          end

          def fully_claimed?
            @guests.count >= @invite_guest.quantity
          end

          def render_error(message)
            render json: { errors: message }
          end

          def guest_params
            params.require(:invite_guest).permit(
              :first_name,
              :last_name,
              :dob,
              :gender,
              :age,
              :emergency_contact,
              :phone_number,
              :address,
              :other_organization
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
