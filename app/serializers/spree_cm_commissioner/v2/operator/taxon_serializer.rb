module SpreeCmCommissioner
  module V2
    module Operator
      class TaxonSerializer < BaseSerializer
        attributes :name, :permalink, :pretty_name
      end
    end
  end
end
