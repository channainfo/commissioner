module Spree
  module Events
    class StateChangesController < Spree::Events::BaseController
      def index
        @guest = SpreeCmCommissioner::Guest.find(params[:guest_id])
        @event = @guest.event
        @state_changes = @guest.state_changes.includes(:user)
      end
    end
  end
end
