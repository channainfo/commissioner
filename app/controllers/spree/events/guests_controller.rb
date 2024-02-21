module Spree
  module Events
    class GuestsController < Spree::Events::BaseController
      helper SpreeCmCommissioner::Admin::GuestHelper

      def collection_url
        event_guests_url
      end

      def model_class
        SpreeCmCommissioner::Guest
      end

      def edit
        @guest = SpreeCmCommissioner::Guest.find(params[:id])
        @event = @guest.event
      end

      def permitted_resource_params
        params.required(:spree_cm_commissioner_guest).permit(:entry_type)
      end

      protected

      def collection
        scope = model_class.where(event_id: current_event.id)

        @search = scope.ransack(params[:q])
        @collection = @search.result
                             .includes(:id_card)
                             .page(params[:page])
                             .per(params[:per_page])
      end
    end
  end
end
