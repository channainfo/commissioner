module Spree
  module V2
    module Tenant
      class UserDeviceTokenSerializer < BaseSerializer
        attributes :user_id, :registration_token, :client_name, :client_version, :meta, :device_type
      end
    end
  end
end
