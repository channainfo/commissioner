module Spree
  module Admin
    class VideoUpload < Spree::Admin::ResourceController
      before_action :product

      def new
        @video_upload = SpreeCmCommissioner::VideoUpload.new
      end

      private

      def model_class
        SpreeCmCommissioner::VideoUpload
      end

      def object_name
        'spree_cm_commissioner_video_upload'
      end

      def collection_url(options = {})
        admin_product_video_uploads_url(options)
      end

    end
  end
end
