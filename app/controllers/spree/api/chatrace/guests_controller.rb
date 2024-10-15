module Spree
  module Api
    module Chatrace
      class GuestsController < BaseController
        def scope
          SpreeCmCommissioner::Guest.complete
        end

        def show
          guest = scope.find_by!(token: params[:id])

          render_serialized_payload { serialize_resource(guest) }
        end

        def update
          guest = scope.find_by!(token: params[:id])

          guest.preferred_telegram_user_id = params[:telegram_user_id]
          guest.preferred_telegram_user_verified_at = DateTime.current

          if guest.save
            render_serialized_payload { serialize_resource(guest) }
          else
            render_error_payload(guest.errors)
          end
        end

        def serialize_resource(guest)
          order = guest.line_item.order

          {
            token: guest.token,
            first_name: guest.first_name,
            last_name: guest.last_name,
            dob: guest.dob,
            gender: guest.gender,
            age: guest.age,
            occupation: guest.occupation&.name || guest.other_occupation,
            entry_type: guest.entry_type,
            organization: guest.other_organization,
            expectation: guest.expectation,
            telegram_user_id: guest.preferred_telegram_user_id,
            telegram_user_verified_at: guest.preferred_telegram_user_verified_at,
            order_number: order.number,
            order_email: order.email,
            order_first_name: order.customer_address&.firstname,
            order_last_name: order.customer_address&.lastname,
            order_phone_number: order.intel_phone_number || order.customer_address&.phone,
            checked_in_at: guest.check_in&.confirmed_at,
            qr_data: guest.qr_data,
            order_qr_data: order.qr_data
          }
        end
      end
    end
  end
end
