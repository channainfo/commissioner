module Spree
  module Admin
    class SystemController < Spree::Admin::ResourceController
      skip_before_action :load_resource

      def show
        @fetcher = SpreeCmCommissioner::WaitingRoomSystemMetadataFetcher.new
        @fetcher.load_document_data

        @active_sesions_count = SpreeCmCommissioner::WaitingRoomSession.active.count
      end

      def modify_multiplier
        modifier = params[:multiplier]&.to_i || 0
        SpreeCmCommissioner::WaitingRoomSystemMetadataSetter.new.modify_multiplier(modifier)

        redirect_back fallback_location: collection_url
      end

      def modify_max_thread_count
        modifier = params[:max_thread_count]&.to_i || 0
        SpreeCmCommissioner::WaitingRoomSystemMetadataSetter.new.modify_max_thread_count(modifier)

        redirect_back fallback_location: collection_url
      end

      def force_pull
        SpreeCmCommissioner::WaitingRoomLatestSystemMetadataPullerJob.perform_now
        SpreeCmCommissioner::WaitingGuestsCallerJob.perform_now

        redirect_back fallback_location: collection_url
      end

      def model_class
        nil
      end

      # override
      def collection_url(options = {})
        admin_system_url(options)
      end
    end
  end
end
