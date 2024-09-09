module Spree
  module Admin
    class WebhooksEventsController < Spree::Admin::ResourceController
      # @overrided
      def collection
        return @collection if @collection.present?

        @q = Spree::Webhooks::Event.ransack(params[:q])
        @collection = @q.result
                        .includes(:subscriber)
                        .page(params[:page])
                        .per(params[:per_page] || 24)
      end

      # @overrided
      def model_class
        Spree::Webhooks::Event
      end
    end
  end
end
