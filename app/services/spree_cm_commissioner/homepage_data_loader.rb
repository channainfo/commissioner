module SpreeCmCommissioner
  class HomepageDataLoader
    include ActiveModel::Serialization

    attr_accessor :id,
                  :config,
                  :homepage_backgrounds, :homepage_background_ids,
                  :homepage_banners, :homepage_banner_ids,
                  :top_categories, :top_category_ids,
                  :display_products, :display_product_ids,
                  :trending_categories, :trending_category_ids,
                  :featured_brands, :featured_brand_ids,
                  :featured_vendors, :featured_vendor_ids

    def initialize
      @config = SpreeCmCommissioner::Configuration.new
    end

    def self.cache_key(_options = {})
      'homepage_data_loader'
    end

    def self.clear_cache(_options = {})
      Rails.cache.delete(cache_key)
    end

    def self.with_cache
      Rails.cache.fetch(cache_key) do
        data_loader = new
        data_loader.call
      end
    end

    def call
      set_record_id
      set_homepage_backgrounds
      set_homepage_banners
      set_featured_vendors

      set_trending_categories
      # set_top_catgories
      # set_display_products
      # set_featured_brands

      self
    end

    def set_record_id
      @id = SecureRandom.hex
    end

    def set_homepage_backgrounds
      @homepage_backgrounds = SpreeCmCommissioner::HomepageBackground.active.includes(app_image: :attachment_blob).order(:priority)
      @homepage_background_ids = @homepage_backgrounds.pluck(:id)
    end

    def set_homepage_banners
      @homepage_banners = SpreeCmCommissioner::HomepageBanner.active.includes(app_image: :attachment_blob).order(:priority)
      @homepage_banner_ids = @homepage_banners.pluck(:id)
    end

    def set_top_catgories
      config_taxon_ids = @config.top_category_taxon_ids
      taxon_ids = config_taxon_ids.present? ? config_taxon_ids.split(',') : []

      return @trending_categories = Spree::Taxon.none if taxon_ids.blank?

      @top_categories = Spree::Taxon.where(id: taxon_ids).limit(4).order(:lft)
      @top_category_ids = @top_categories.map(&:id)
    end

    def set_trending_categories
      config_taxon_ids = @config.trending_category_taxon_ids
      taxon_ids = config_taxon_ids.present? ? config_taxon_ids.split(',') : []

      return @trending_categories = Spree::Taxon.none if taxon_ids.blank?

      @trending_categories = Spree::Taxon.where(id: taxon_ids).limit(5).order(:lft)
      @trending_category_ids = @trending_categories.map(&:id)
    end

    def set_featured_brands
      config_taxon_ids = @config.featured_brand_taxon_ids
      taxon_ids = config_taxon_ids.present? ? config_taxon_ids.split(',') : []

      return @featured_brands = Spree::Taxon.none if taxon_ids.blank?

      @featured_brands = Spree::Taxon.where(id: taxon_ids).limit(12).order(:lft)
      @featured_brand_ids = @featured_brands.map(&:id)
    end

    def set_featured_vendors
      config_vendor_ids = @config.featured_vendor_ids
      vendor_ids = config_vendor_ids.present? ? config_vendor_ids.split(',') : []

      return @featured_vendors = Spree::Vendor.none if vendor_ids.blank?

      @featured_vendors = Spree::Vendor.where(id: vendor_ids)
      @featured_vendor_ids = @featured_vendors.pluck(:id)
    end

    def set_display_products
      config_taxon_ids = @config.displayed_product_taxon_ids
      taxon_ids = config_taxon_ids.present? ? config_taxon_ids.split(',') : []

      return @display_products = Spree::Taxon.none if taxon_ids.blank?

      @display_products = SpreeCmCommissioner::Feed::TaxonProduct.call(taxon_ids, limit: 6, serialize_data: true)
      @display_product_ids = @display_products.map(&:id)
    end
  end
end
