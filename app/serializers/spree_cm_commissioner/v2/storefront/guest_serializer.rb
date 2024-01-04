module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :line_item_id, :dob, :gender, :created_at, :updated_at

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer
      end
    end
  end
end
