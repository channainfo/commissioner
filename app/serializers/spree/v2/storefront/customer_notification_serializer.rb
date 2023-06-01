module Spree
  module V2
    module Storefront
      class CustomerNotificationSerializer < BaseSerializer
        set_type :customer_notification

        attributes :title, :body, :payload, :url, :started_at, :send_at, :notification_type

        has_many :feature_image, serializer: :feature_image
      end
    end
  end
end
