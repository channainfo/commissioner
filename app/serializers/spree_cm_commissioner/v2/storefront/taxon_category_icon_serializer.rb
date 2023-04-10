module SpreeCmCommissioner
  module V2
    module Storefront
      class TaxonCategoryIconSerializer < BaseSerializer
        set_type :taxon_category_icon

        attributes :viewable_type, :viewable_id, :styles
      end
    end
  end
end
