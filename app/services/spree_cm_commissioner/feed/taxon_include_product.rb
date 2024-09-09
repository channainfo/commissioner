module SpreeCmCommissioner
  module Feed
    class TaxonIncludeProduct
      include ActiveModel::Serialization

      attr_accessor :id, :name, :description, :permalink, :pretty_name, :products, :product_ids

      def initialize(taxon:, products:)
        @id = taxon.id
        @name = taxon.name
        @description = taxon.description
        @permalink = taxon.permalink
        @pretty_name = taxon.pretty_name

        @products = products
        @product_ids = products.map(&:id)
      end
    end
  end
end
