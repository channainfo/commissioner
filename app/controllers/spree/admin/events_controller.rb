module Spree
  module Admin
    class EventsController < Spree::Admin::ResourceController
      before_action :load_event

      def index
        render :index
      end

      private

      def model_class
        SpreeCmCommissioner::Events
      end

      def load_event
        @events = Spree::Taxon.all
      end
    end
  end
end
