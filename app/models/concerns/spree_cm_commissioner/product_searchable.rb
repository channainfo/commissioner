module SpreeCmCommissioner
  module ProductSearchable
    extend ActiveSupport::Concern

    PRICE_RANGES = [
      {to: 20.0},
      {from: 20.0, to: 50.0},
      {from: 50.0, to: 199.0},
      {from: 199.0 }
    ].freeze

    class_methods do
      def autocomplete(keyword, options = {})
        term = keyword.presence || '*'

        search_options = {
          fields: autocomplete_fields,
          load: false,
          limit: 10,
          misspellings: { below: 3 },
          where: where_options(options),
        }

        search_options.merge!(boost_options(options))

        result = search(term, **search_options)
        result.map(&:name).map(&:strip)
      end

      def boost_options(options)
        {
          boost_where: boost_where(options),
          boost_by: boost_by,
          boost_by_recency: boost_by_recency
        }
      end

      def autocomplete_fields
        fields_options
      end

      def fields_options
        [
          { 'name^10': :word_middle },
          { 'vendor_name^5': :word_middle },
          { 'description^1': :text_middle }
        ]
      end

      def load_includes_assoc
        [
          master: [
            :prices,
            { images: { attachment_attachment: :blob }}
          ],
        ]
      end

      def advanced_search_options(keyword_query, options = {})
        search_options = {
          fields: fields_options,
          suggest: true,
          operator: "or",
          where: where_options(options),
          page: page(options),
          per_page: per_page(options),
        }

        if options[:order_by].blank?
          search_options.merge!(boost_options(options))
        else
          search_options.merge!(order: order_options(options))
        end

        search_options[:misspellings] = keyword_query.length >= 10 ? false : ({ below: 3 })

        if ignore_aggs == false
          search_options.merge!(smart_aggs: true, aggs: aggregations)
        end

        if ignore_products == false
          search_options[:includes] = load_includes_assoc
        end

        # must contains keywords ( no empty ) and the first page
        if keyword_query.present? && keyword_query != "*" && page == 1 && options[:user_id].present?
          search_options.merge!(track: { user_id: options[:user_id] })
        end

        search_options
      end

      def advanced_search(keyword_query, options = {})
        search_options = advanced_search_options(keyword_query, options)
        search(keyword_query, search_options)
      end

      def boost_where(options)
        return { purchaser_ids: options[:user_id] } if options[:user_id].present?

        nil
      end

      def boost_by_recency
        { created_at: { scale: '7d', decay: 0.5 } }
      end

      def boost_by
        {
          conversions_count: { factor: 10 },
          whishedlists_count: { factor: 3 },
          impressions_count: { factor: 2 },
          review_rating: { factor: 1 },
          vendor_rating: { factor: 1 }
        }
      end

      def where_options(options)
        filters = {
          active: true
        }

        filters[:product_type] = options[:product_type] if options[:product_type].present?
        filters[:vendor_id] = options[:vendor_id] if options[:vendor_id].present?

        filters
      end

      def page(options)
        return 1 if options[:page].blank?

        options[:page].to_i
      end

      def per_page(options)
        return 12 if options[:per_page].blank?

        options[:per_page].to_i
      end

      def order_options(options)
        order_params = {}

        order_column = options[:order_by]

        if order_column == 'newest-first'
          order_params[:created_at] = :desc
        elsif order_column == 'trending'
          order_params[:conversions] = :desc
        elsif order_column == 'discount'
          order_params[:discount] = :desc
        elsif order_column == 'price-low-to-high'
          order_params[:price] = :asc
        elsif order_column == 'price-high-to-low'
          order_params[:price] = :desc
        else
          order_params[:_score] = :desc
        end

        order_params
      end

      # *-10.0, 10.0-20.0, 20.0-*
      # gte, lte
      def price_range(price)
        return nil if price_param.blank?

        (from, to) = price_param.split('-')
        if(from == '*')
          { lt: to }
        elsif (to == "*" )
          {gte: from }
        else
          { gte: from, lt: to }
        end
      end

      def aggregations
        # query_options = { where: where_query }
        # limit aggregations items to be 24 max
        query_options = { min_doc_count: 1, limit: 24 }
        aggs = { }
        aggregation_fields = fetch_aggregation_fields

        aggregation_fields.each do |filter_name|
          if filter_name == :price
            aggs[filter_name] = { ranges: PRICE_RANGES }
          else
            aggs[filter_name] = query_options
          end
        end

        aggs
      end

      def fetch_aggregation_fields
        fields = [:vendor_id, :price]

        aggregation_classes = [
          Spree::Property,
          Spree::OptionType
        ]

        # property(1), option_type(2) => p_1, o_2
        aggregation_classes.each do |agg_class|
          agg_class.filterable.each do |record|
            fields << record.filter_name
          end
        end

        fields
      end
    end
  end
end
