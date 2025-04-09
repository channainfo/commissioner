module Spree
  module V2
    module Organizer
      class InviteSerializer < BaseSerializer
        attributes :token, :expires_at
        belongs_to :taxon, serializer: Spree::V2::Organizer::TaxonSerializer
        belongs_to :inviter, serializer: Spree::V2::Organizer::UserSerializer
      end
    end
  end
end
