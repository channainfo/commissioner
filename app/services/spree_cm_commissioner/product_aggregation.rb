module SpreeCmCommissioner
  class ProductAggregation
    def initialize(aggs, options={})
      @aggs = aggs
      @options = options
    end

    def add_aggregator(agg_name)
      buckets = @aggs[agg_name]['buckets']
      buckets = agg_bucket_display_name(agg_name,buckets)

      display_name = dynamic_display_name(agg_name)
      aggregator = SpreeCmCommissioner::ProductAggregator.new(agg_name, display_name, buckets, @options)
      @result << aggregator
    end

    def dynamic_display_name(name)
      if name == 'category_ids'
        I18n.t('aggs.categories.name')
      elsif name == 'brand_ids'
        I18n.t('aggs.brands.name')
      elsif name == 'price'
        I18n.t('aggs.price.name')
      elsif( property_agg?(name ) )
        id = name[3..-1]
        @properties[id.to_i]&.name || name
      elsif(option_type_agg?(name))
        id = name[3..-1]
        @option_types[id.to_i]&.name || name
      else
        name
      end
    end

    def agg_bucket_display_name(agg_name, buckets)
      buckets.each do |bucket|
        object_id = bucket['key']
        if taxon_agg?(agg_name)
          bucket['display_name'] = @categories_brands[object_id]&.name || bucket['key']
        elsif property_agg?(agg_name)
          bucket['display_name'] = @product_properties[object_id]&.value || bucket['key']
        elsif option_type_agg?(agg_name)
          bucket['display_name'] = @option_values[object_id]&.name || bucket['key']
        elsif price_agg?(agg_name)
          bucket['display_name'] = SpreeCmCommissioner::PriceAggregator.new(bucket['key'], @options[:currency]).display
        end
      end

      buckets
    end

    def any_filter_applied?(params)
      @aggs.keys.each do |key|
        return true if !params[key].nil?
      end
      false
    end

    def call
      return @result if !@result.nil?
      @result = []
      load_filter_record_from_keys

      prioritized_keys = ['category_ids', 'brand_ids', 'price' ]
      other_keys = @aggs.keys - prioritized_keys
      keys = prioritized_keys + other_keys

      keys.each do |key|
        add_aggregator(key) if @aggs[key].present?
      end

      @result
    end

    # prefixes: fp_, fo_
    def tranform_key_to_id(key)
      key[3..-1]
    end

    def taxon_agg?(key)
      key == 'category_ids' || key == 'brand_ids'
    end

    def price_agg?(key)
      key == 'price'
    end

    def property_agg?(key)
      key.start_with?(Spree::Property.filter_separator)
    end

    def option_type_agg?(key)
      key.start_with?(Spree::OptionType.filter_separator)
    end

    # fo_, fp_
    def load_filter_record_from_keys
      # aggs field
      option_type_ids = {}
      property_ids = {}

      # aggs value
      product_property_ids = {}
      option_value_ids = {}
      taxon_ids = {}

      @aggs.keys.each do |key|
        next if key == 'price'

        # category and brand aggs
        if taxon_agg?(key)
          @aggs[key]['buckets'].each do |bucket|
            id = bucket['key']
            taxon_ids[id] = id
          end

        # property aggs
        elsif property_agg?(key)
          agg_field_id = tranform_key_to_id(key)
          property_ids[agg_field_id] = agg_field_id

          @aggs[key]['buckets'].each do |bucket|
            id = bucket['key']
            product_property_ids[id] = id
          end

        # option type aggs
        elsif option_type_agg?(key)
          agg_field_id = tranform_key_to_id(key)
          option_type_ids[agg_field_id] = agg_field_id

          @aggs[key]['buckets'].each do |bucket|
            id = bucket['key']
            option_value_ids[id] = id
          end
        end
      end

      # load categories and brands
      if(taxon_ids.present?)
        query_loader = Spree::Taxon.select('id').where(id: taxon_ids.keys)
        @categories_brands = query_loader.index_by(&:id)
      else
        @categories_brands = {}
      end

      # load properties
      if(property_ids.present?)
        query_loader = Spree::Property.select('id').where(id: property_ids.keys)
        @properties = query_loader.index_by(&:id)
      else
        @properties = {}
      end

      # load option types
      if(option_type_ids.present?)
        query_loader = Spree::OptionType.select('id').where(id: option_type_ids.keys)
        @option_types = query_loader.index_by(&:id)
      else
        @option_types = {}
      end

      # load product properties
      if(product_property_ids.present?)
        query_loader = Spree::ProductProperty.select('id').where(id: product_property_ids.keys)
        @product_properties = query_loader.index_by(&:id)
      else
        @product_properties = {}
      end

      # load option values
      if(option_value_ids.present?)
        query_loader = Spree::OptionValue.select('id').where(id: option_value_ids.keys)
        @option_values = query_loader.index_by(&:id)
      else
        @option_values = {}
      end

    end
  end
end
