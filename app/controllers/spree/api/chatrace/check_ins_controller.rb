module Spree
  module Api
    module Chatrace
      class CheckInsController < BaseController
        def guest
          @guest ||= SpreeCmCommissioner::Guest.complete.find_by!(token: params[:guest_token])
        end

        def create
          context = SpreeCmCommissioner::CheckInBulkCreator.call(guest_ids: [guest.id])
          if context.success?
            render json: { checked_in_at: context.check_ins[0].confirmed_at }, status: :ok
          else
            render_error_payload(context.message)
          end
        end
      end
    end
  end
end
