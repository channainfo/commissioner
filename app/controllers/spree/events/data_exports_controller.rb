module Spree
  module Events
    class DataExportsController < Spree::Events::BaseController
      rescue_from StandardError do |exception|
        flash[:error] = exception.message
        redirect_to event_data_exports_path
      end

      # override
      def model_class
        SpreeCmCommissioner::Export
      end

      # POST: /data_exports/:id/download
      def download
        export = SpreeCmCommissioner::Export.find_by(uuid: params[:id])

        raise StandardError, 'Export file is not attached or export is not done' unless export.exported_file.attached? && export.done?

        redirect_to main_app.rails_blob_url(export.exported_file, expires_in: 3600.seconds)
        # HOST/events/events-tedxphnompenh-2024/data_exports/9313a0c9-5d1f-4c26-983a-f8b796ec141f/download
      end

      private

      # override
      def collection
        @collection = model_class.all
                                 .page(params[:page])
                                 .per(params[:per_page])
                                 .order(created_at: :desc)
      end

      # override
      def collection_actions
        super << :download
      end
    end
  end
end
