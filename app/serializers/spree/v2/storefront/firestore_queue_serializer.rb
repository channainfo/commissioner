module Spree
  module V2
    module Storefront
      class FirestoreQueueSerializer < BaseSerializer
        attributes :status, :queued_at
      end
    end
  end
end
