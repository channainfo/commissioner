module SpreeCmCommissioner
  module V2
    module Operator
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer
      end
    end
  end
end
