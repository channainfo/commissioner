module Spree
  module V2
    module Storefront
      class UserDeviceTokenSerializer < BaseSerializer
        attributes :user_id, :registration_token, :client_name, :client_version, :meta
      end
    end
  end
end
