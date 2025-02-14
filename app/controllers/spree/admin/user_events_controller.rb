module Spree
  module Admin
    class UserEventsController < Spree::Admin::ResourceController
      before_action :load_parents, if: -> { params[:taxon_id].present? }

      # override
      def index
        if params[:taxon_id].present?
          @user_events = @taxon.user_events
        else
          @user = Spree::User.find(params[:user_id])
          @user_events = @user.user_events
        end
      end

      # override
      def new
        @user = spree_current_user
      end

      # override
      def create
        user_event = SpreeCmCommissioner::UserEvent.new(permitted_resource_params)

        if user_event.save
          flash[:success] = flash_message_for(user_event, :successfully_created)
        else
          flash[:error] = user_event.errors.full_messages.join(', ')
        end
        redirect_back(fallback_location: collection_url)
      end

      private

      def load_parents
        @taxon = Spree::Taxon.find(params[:taxon_id])
        @taxonomy = @taxon.taxonomy
      end

      # override
      def model_class
        SpreeCmCommissioner::UserEvent
      end

      # override
      def object_name
        'spree_cm_commissioner_user_event'
      end

      # override
      def collection_url
        admin_user_events_path
      end

      # override
      def permitted_resource_params
        params.require(:spree_cm_commissioner_user_event).permit(:taxon_id, :user_id)
      end
    end
  end
end
