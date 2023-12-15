module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :taxon_id, :line_item_id, :dob, :gender, :created_at, :updated_at
      end
    end
  end
end
