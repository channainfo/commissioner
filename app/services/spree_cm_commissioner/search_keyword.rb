module SpreeCmCommissioner
  class SearchKeyword
    attr_reader :keywork, :options

    include ::Spree::Api::V2::DisplayMoneyHelper
    include SpreeCmCommissioner::CustomProductSerializable

    # current_user:, current_currency:, reranking: , per_page:,
    # ignore_aggs:, ignore_products:, keywords:
    def initialize(keyword, options = {})
      @keyword = keyword
      @options = options

      set_page
      set_per_page
      set_ignore_aggs
      set_ignore_products
    end

    def call
      result = {
        id: SecureRandom::hex,
        aggregators: aggregators,
        suggestions: suggestions,
        products: products,
        taxon: taxon,
        meta: meta,
        sjid: search_result.search&.id,
        recommendation_id: recommendation_id,
      }

      SearchKeywordResult.new(result)
    end

    private

    def default_rerank_per_page
      12
    end

    def page
      @options[:page]
    end

    def per_page
      @options[:per_page]
    end

    def allow_search_rerank?
      ENV['SEARCH_RERANK'] == 'yes'
    end

    def enable_reranking?
      return false if !allow_search_rerank?
      @options[:reranking].present? && page == 1
    end

    def ignore_aggs?
      @options[:ignore_aggs]
    end

    def ignore_products?
      @options[:ignore_products]
    end

    def ignore_detailed_images?
      @options[:ignore_detailed_images] == 'yes'
    end

    def search_result
      @search_result ||= Spree::Product.advanced_search(keyword, options)
    end

    def taxon
      return nil if ignore_products?
      return nil if @options[:taxon].blank?
      @taxon = Spree::Taxon.find(@options[:taxon])
      {
        id: @taxon.id,
        name: @taxon.name,
        description: @taxon.description,
        permalink: @taxon.permalink,
        header_banner: @taxon.icon&.styles || [],
      }

      # style_resize_and_pad(:large)
    end

    def aggregators
      return [] if ignore_aggs?
      aggregation = SpreeCmCommissioner::ProductAggregation.new(search_result.aggs, currency: @options[:current_currency] )
      result = aggregation.call
      result
    end

    def suggestions
      search_result.suggestions
    end

    def meta
      {
        total_count: search_result.total_count,
        total_pages: search_result.total_pages,
        current_page: search_result.current_page,
      }
    end

    def product_ids
      search_result.map(&:id)
    end

    def products_index_by_id
      return @products_index_by_id if !@products_index_by_id.nil?
      @products_index_by_id = {}

      search_result.each do |product|
        product_id = product.id
        @products_index_by_id["#{product_id}"] = product_data(product)
      end

      @products_index_by_id
    end

    def product_data(product)
      {
        id: product.id,
        sku: product.sku,
        name: product.name,
        slug: product.slug,

        available_on: product.available_on,

        price: SpreeCmCommissioner::SearchKeyword.price(product, @options[:current_currency]),
        display_price: SpreeCmCommissioner::SearchKeyword.display_price(product, @options[:current_currency]),
        compare_at_price: SpreeCmCommissioner::SearchKeyword.compare_at_price(product, @options[:current_currency]),
        display_compare_at_price: SpreeCmCommissioner::SearchKeyword.display_compare_at_price(product, @options[:current_currency]),
        currency: @options[:current_currency],

        event_start_date: product.event_start_date,
        event_end_date: product.event_end_date,
        event_discount: product.event_discount,
        is_effective_flash_sale: product.is_effective_flash_sale?,

        images: product_master_images(product, ignore_detailed_images?),
        vendor: product_vendor(product),
        recommendation_id: recommendation_id
      }
    end

    def products_from_es
      search_result.map {|product| product_data(product)}
    end

    def user_id
      @options[:user_id] || @options[:current_user]&.id
    end

    def recommendation_id
      @recommendation_id
    end

    def products_from_reranking
      products_from_es
    end

    def total_count
      search_result.total_count
    end

    def rerankable?
      return false if total_count < 10
      return false if !enable_reranking?
      return false if !user_id
      return false if @options[:keywords].blank? || @options[:keywords] == '*'
      true
    end

    def products
      return [] if ignore_products?
      rerankable? ? products_from_reranking : products_from_es
    end

    def set_page
      if @options[:page].present? && @options[:page].to_i > 1
        @options[:page] =  @options[:page].to_i
      else
        @options[:page] = 1
      end
    end

    def set_per_page
      if @options[:per_page].present?
        @options[:per_page] =  @options[:per_page].to_i
      elsif enable_reranking?
        @options[:per_page] = default_rerank_per_page
      else
        @options[:per_page] = 12
      end
    end

    def set_ignore_aggs
      if @options[:ignore_aggs].nil? && page == 1
        @options[:ignore_aggs] = false
      end
    end

    def set_ignore_products
      if @options[:ignore_products].nil?
        @options[:ignore_products] = false
      end
    end
  end
end
