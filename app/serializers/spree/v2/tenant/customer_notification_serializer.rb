module Spree
  module V2
    module Tenant
      class CustomerNotificationSerializer < BaseSerializer
        attributes :title, :payload, :body, :url, :started_at, :sent_at, :notification_type, :action_label

        has_many :feature_images, serializer: Spree::V2::Tenant::AssetSerializer
      end
    end
  end
end
