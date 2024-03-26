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
        @collection = model_class.all
                                 .page(params[:page])
                                 .per(params[:per_page])
      end
    end
  end
end
