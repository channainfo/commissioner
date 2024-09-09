module SpreeCmCommissioner
  module V2
    module Operator
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :qr_data, :event_id, :seat_number, :formatted_bib_number, :phone_number

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer

        has_one :check_in, serializer: SpreeCmCommissioner::V2::Operator::CheckInSerializer
        has_one :line_item, serializer: SpreeCmCommissioner::V2::Operator::LineItemSerializer
      end
    end
  end
end
