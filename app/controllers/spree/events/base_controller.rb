module Spree
  module Events
    class BaseController < Spree::Admin::ResourceController
      include SpreeCmCommissioner::Events::RoleAuthorization

      layout 'spree/layouts/event'

      before_action :required_user_event!

      helper_method :current_event

      def default_url_options
        super.merge(event_id: params[:event_id] || events.first&.slug)
      end

      def events
        @events ||= spree_current_user.events
      end

      def current_event
        if params[:event_id].blank?
          @current_event = events.first
        else
          @current_event ||= events.find_by!(slug: params[:event_id])
        end
      end

      def required_user_event!
        return if current_event.present?

        raise SpreeCmCommissioner::UnauthorizedEventError
      end
    end
  end
end
