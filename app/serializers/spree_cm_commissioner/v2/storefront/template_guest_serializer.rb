module SpreeCmCommissioner
  module V2
    module Storefront
      class TemplateGuestSerializer < BaseSerializer
        attributes :first_name, :last_name, :dob, :gender, :is_default, :phone_number, :emergency_contact,
                   :occupation_id, :other_occupation, :nationality_id, :user_id,
                   :deleted_at, :created_at, :updated_at

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer
        belongs_to :nationality, serializer: Spree::V2::Storefront::TaxonSerializer

        has_one :id_card, serializer: Spree::V2::Storefront::IdCardSerializer
      end
    end
  end
end
