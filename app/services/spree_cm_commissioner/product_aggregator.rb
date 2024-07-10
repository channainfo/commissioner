module SpreeCmCommissioner

  class ProductAggregator
    attr_accessor :name, :display_name, :count, :buckets

    VISIBLE_BUCKET_SIZE = 5

    def initialize(name, display_name, buckets, options = {})
      @name    = name
      @display_name = display_name
      @buckets = buckets || []
      @options = options
    end

    def count
      return @count if @count.present?

      @count = 0

      @buckets.each do |bucket|
        @count += bucket['doc_count']
      end

      @count
    end

    def should_show_more?
      buckets.count > Vshop::ProductAggregator::VISIBLE_BUCKET_SIZE
    end

    def should_display?
      return true if name == 'category_ids' && @buckets.count > 0
      return true if name == 'brand_ids' && @buckets.count > 0
      @buckets.count > 1
    end

    def display_value(bucket)
      if(name == 'price')
        result = Vshop::PriceAggregator.new(bucket['key'], @options[:currency]).display
      else
        result = bucket['display_name'] || bucket['key']
      end
      result
    end
  end
end
