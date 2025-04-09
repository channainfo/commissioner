module Spree
  module V2
    module Tenant
      class NotificationSerializer < BaseSerializer
        set_type :notification

        attributes :read_at, :created_at, :params, :type
      end
    end
  end
end
