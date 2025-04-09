module Spree
  module Api
    module V2
      module Organizer
        class InvitesController < ::Spree::Api::V2::Organizer::BaseController
          def show
            if invite&.url_valid?
              render_serialized_payload { serialize_resource(invite) }
            else
              render_error_payload(I18n.t('invite.url_not_found'))
            end
          end

          def update
            context = invite.confirm(params[:user_id])

            if context.success?
              render_serialized_payload { serialize_resource(context.invite) }
            else
              render_error_payload(context.message || I18n.t('invite.accept_fail'))
            end
          end

          def invite
            @invite ||= SpreeCmCommissioner::Invite.find_by!(token: params[:id])
          end

          def resource_serializer
            ::Spree::V2::Organizer::InviteSerializer
          end
        end
      end
    end
  end
end
