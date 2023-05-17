module Spree
  module Admin
    class FeatureImagesController < Spree::Admin::ResourceController
      before_action :load_customer_notification

      create.before :set_viewable
      update.before :set_viewable

      def load_customer_notification
        @customer_notification ||= SpreeCmCommissioner::CustomerNotification.find_by(id: params[:customer_notification_id])
      end

      def set_viewable
        load_customer_notification
        @object.viewable_type = viewable_type
        @object.viewable_id = viewable_id
      end

      def viewable_type
        @customer_notification.class.name
      end

      def viewable_id
        @customer_notification.id
      end

      def model_class
        SpreeCmCommissioner::FeatureImage
      end

      def collection
        load_customer_notification
        @objects = model_class.where(
          viewable_type: viewable_type,
          viewable_id: viewable_id
        )
      end

      # @overrided
      def object_name
        'spree_cm_commissioner_feature_image'
      end

      # @overrided
      def collection_url(options = {})
        admin_customer_notification_feature_images_url(options)
      end
    end
  end
end
