module SpreeCmCommissioner
  module V2
    module Storefront
      class TaxonBrandLogoSerializer < BaseSerializer
        set_type :taxon_brand_logo

        attributes :viewable_type, :viewable_id, :mobile_styles
      end
    end
  end
end
