module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :created_at, :updated_at
        attribute :valid, &:valid?

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer
        has_one :id_card, serializer: Spree::V2::Storefront::IdCardSerializer
      end
    end
  end
end
