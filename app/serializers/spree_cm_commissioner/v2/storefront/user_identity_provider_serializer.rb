module SpreeCmCommissioner
  module V2
    module Storefront
      class UserIdentityProviderSerializer < BaseSerializer
        set_type :user_identity_provider

        attributes :identity_type, :sub
      end
    end
  end
end
