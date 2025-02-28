module Spree
  module V2
    module Tenant
      class UserIdentityProviderSerializer < BaseSerializer
        set_type :user_identity_provider

        attributes :identity_type, :sub, :email, :name
      end
    end
  end
end
