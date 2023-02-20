module Spree
  module V2
    module Storefront
      module TaxonSerializerDecorator
        def self.prepended(base)
          base.has_one :category_icon, serializer: SpreeCmCommissioner::V2::Storefront::CategoryIconSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::TaxonSerializer.prepend(Spree::V2::Storefront::TaxonSerializerDecorator)
