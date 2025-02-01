module Spree
  module V2
    module Billing
      class TaxonomySerializer < Spree::V2::Storefront::BaseSerializer
        attributes :id, :name, :position
      end
    end
  end
end
