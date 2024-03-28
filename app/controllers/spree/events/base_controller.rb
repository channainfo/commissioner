module Spree
  module Events
    class BaseController < Spree::Admin::ResourceController
      include SpreeCmCommissioner::Events::RoleAuthorization

      layout 'spree/layouts/event'

      before_action :required_user_event!
      before_action :current_event

      helper_method :current_event

      rescue_from SpreeCmCommissioner::UnauthorizationError, with: :handle_unauthorized_event

      def index
        redirect_to event_guests_path(current_event.slug)
      end

      def events
        @events ||= spree_current_user.events.to_a
      end

      def current_event
        @current_event ||= Spree::Taxon.find_by(slug: params[:event_id])
      end

      def handle_unauthorized_event
        redirect_to forbidden_events_path
      end

      def required_user_event!
        return unless events.empty?

        raise SpreeCmCommissioner::UnauthorizationError
      end
    end
  end
end
