module Spree
  module Events
    class BaseController < Spree::Admin::ResourceController
      layout 'spree/layouts/event'

      helper_method :current_event

      def current_event
        @current_event ||= Spree::Taxon.find_by(slug: params[:event_id])
      end
    end
  end
end
