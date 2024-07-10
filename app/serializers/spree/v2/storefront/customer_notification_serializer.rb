module Spree
  module V2
    module Storefront
      class CustomerNotificationSerializer < BaseSerializer
        set_type :customer_notification

        attributes :title, :payload, :body, :url, :started_at, :sent_at, :notification_type, :action_label

        # deprecated
        has_one :feature_image, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer

        has_many :feature_images, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
