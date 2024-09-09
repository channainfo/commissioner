module Spree
  module Api
    module V2
      module Storefront
        class UserDeletionReasonsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            ::UserDeletionReason.all
          end

          def collection_serializer
            ::Spree::V2::Storefront::UserDeletionReasonSerializer
          end
        end
      end
    end
  end
end
