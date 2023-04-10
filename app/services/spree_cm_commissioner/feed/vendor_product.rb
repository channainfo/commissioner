module SpreeCmCommissioner
  module Feed
    class VendorProduct
      attr_accessor :vendor

      LIMIT = 4

      def initialize(vendor:, products:)
        @vendor = vendor
        @products = products
      end

      def products
        (@products.presence || [])
      end

      def self.call(vendor_ids, options = {})
        limit = options[:limit] || LIMIT
        from_mobile = options[:from_mobile] || false
        return [] if vendor_ids.blank?

        vendors = Spree::Vendor.includes(:translations).where(id: vendor_ids).order(priority: :desc)
        vendors = vendors.includes(app_promotion_banner: :attachment_blob) if from_mobile

        sub_query = query_product_in_vendor(vendor_ids).to_sql

        vendor_products = Spree::Product.select('*').from(" ( #{sub_query} ) AS spree_products")
                                        .where(['spree_products.product_top_rank <= ?', limit])
                                        .includes(:translations, master: :prices)

        vendor_products = vendor_products.to_a

        vendors.map do |vendor|
          serilize_class = serilize_class(options[:serialize_data])

          products = vendor_products.select { |vendor_product| vendor_product.vendor_id == vendor.id }
          serilize_class.new(vendor: vendor, products: products)
        end
      end

      def self.serilize_class(serialize_data)
        serialize_data ? SpreeCmCommissioner::Feed::VendorIncudeProduct : SpreeCmCommissioner::Feed::VendorProduct
      end

      def self.query_product_in_vendor(vendor_ids)
        select_stm = 'spree_products.*, DENSE_RANK() OVER( PARTITION BY vendor_id ORDER BY created_at DESC ) AS product_top_rank'
        SpreeCmCommissioner::Feed.query_active_products.select(select_stm)
                                 .where(vendor_id: vendor_ids)
      end
    end
  end
end
