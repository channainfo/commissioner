module SpreeCmCommissioner
  module Feed
    class DisplayProduct
      LIMIT = 6

      def self.call
        new.call
      end

      def call
        Spree::Product.select('*')
                      .from(" (#{rank_sale_product.to_sql}) AS spree_products")
                      .where(['spree_products.product_top_rank <= ?', LIMIT])
      end

      def rank_sale_product
        select_stm = 'spree_products.*, DENSE_RANK() OVER( PARTITION BY vendor_id ORDER BY created_at DESC ) AS product_top_rank'
        SpreeCmCommissioner::Feed.query_active_products.select(select_stm)
      end
    end
  end
end
