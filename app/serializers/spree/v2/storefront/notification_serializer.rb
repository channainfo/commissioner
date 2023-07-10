module Spree
  module V2
    module Storefront
      class NotificationSerializer < BaseSerializer
        set_type :notification

        attributes :read_at, :created_at, :params
      end
    end
  end
end
