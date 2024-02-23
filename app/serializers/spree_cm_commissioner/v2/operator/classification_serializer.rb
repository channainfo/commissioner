module SpreeCmCommissioner
  module V2
    module Operator
      class ClassificationSerializer < BaseSerializer
        attributes :total_count

        belongs_to :product, serializer: :product
        belongs_to :taxon, serializer: :taxon
      end
    end
  end
end
