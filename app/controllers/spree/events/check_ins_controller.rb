module Spree
  module Events
    class CheckInsController < Spree::Events::BaseController
      helper SpreeCmCommissioner::Admin::GuestHelper

      def collection_url
        event_check_ins_url
      end

      def model_class
        SpreeCmCommissioner::CheckIn
      end

      private

      def collection
        scope = current_event.check_ins

        @collection = scope.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
