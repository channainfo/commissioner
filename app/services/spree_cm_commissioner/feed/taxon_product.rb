module SpreeCmCommissioner
  module Feed
    class TaxonProduct
      attr_accessor :taxon

      LIMIT = 4

      def initialize(taxon:, products:)
        @taxon    = taxon
        @products = products
      end

      def products
        (@products.presence || [])
      end

      def self.call(taxon_ids, options = {})
        limit = options[:limit] || LIMIT

        return [] if taxon_ids.blank?

        taxons = Spree::Taxon.where(id: taxon_ids).order(:lft)

        sub_query = query_product_in_taxon(taxon_ids).to_sql

        taxon_products = Spree::Product.select('spree_products.*, rank_taxon_products.taxon_id as taxon_id')
                                       .joins("INNER JOIN (#{sub_query}) AS rank_taxon_products ON spree_products.id= rank_taxon_products.product_id")
                                       .where(['rank_taxon_products.product_top_rank <= ?', limit])
                                       .includes(master: :prices)

        taxon_products = taxon_products.to_a

        taxons.map do |taxon|
          serilize_class = serilize_class(options[:serialize_data])

          # taxon_product contain attribute taxon_id get from the query above
          products = taxon_products.select { |taxon_product| taxon_product.read_attribute_before_type_cast('taxon_id') == taxon.id }
          serilize_class.new(taxon: taxon, products: products)
        end
      end

      def self.serilize_class(serialize_data)
        serialize_data ? SpreeCmCommissioner::Feed::TaxonIncludeProduct : SpreeCmCommissioner::Feed::TaxonProduct
      end

      def self.query_product_in_taxon(taxon_ids)
        select_stm = 'spree_products_taxons.*, DENSE_RANK() OVER( PARTITION BY taxon_id ORDER BY position ASC ) AS product_top_rank'
        Spree::Classification.select(select_stm)
                             .where(taxon_id: taxon_ids) # classifications table is spree_products_taxons
                             .where("product_id in (#{SpreeCmCommissioner::Feed.query_active_products.select('id').to_sql})")
      end
    end
  end
end
