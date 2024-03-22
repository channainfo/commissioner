module Spree
  module Events
    class DataExportsController < Spree::Events::BaseController
      # override
      def model_class
        SpreeCmCommissioner::Export
      end

      # POST: /data_exports/download
      def download
        export = SpreeCmCommissioner::Export.find_by(uuid: params[:export])

        return unless export.exported_file.attached? && export.done?

        redirect_to main_app.rails_blob_url(export.exported_file, expires_in: 3600.seconds)
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
