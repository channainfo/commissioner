module SpreeCmCommissioner
  module V2
    module Operator
      class LineItemSerializer < BaseSerializer
        set_type :line_item

        attributes :name, :quantity

        belongs_to :order, serializer: SpreeCmCommissioner::V2::Operator::LineItemOrderSerializer

        has_many :guests, serializer: SpreeCmCommissioner::V2::Operator::GuestSerializer
      end
    end
  end
end
