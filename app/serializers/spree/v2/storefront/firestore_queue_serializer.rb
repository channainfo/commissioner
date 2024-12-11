module Spree
  module V2
    module Storefront
      class FirestoreQueueSerializer < BaseSerializer
        attributes :status, :queued_at, :collection_reference, :document_reference
      end
    end
  end
end
