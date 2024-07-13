module SpreeCmCommissioner
  module ProductIndexable
    extend ActiveSupport::Concern

    included do
      searchkick word_middle: %i[name vendor_name],
                 searchable: %i[name vendor_name description],
                 text_middle: %i[description],
                 suggest: %i[name vendor_name]
    end

    def review_rating
      0
    end

    def vendor_rating
      0
    end

    def impressions_count
      0
    end

    def conversions_count
      0
    end

    def whishedlists_count
      0
    end

    # [ variants_including_master: {option_values: { option_type: :translations } }]
    def filterable_option_types_for_es_index
      json = {}

      # [{ size: 'M', color: 'Red', conditon: 'Good'}, { size: 'L', color: 'Red', conditon: 'Good'}]
      variants_including_master.each do |v|
        v.option_values.each do |option_value|
          option_type = option_value.option_type
          next if !option_type.filterable?

          index_key = option_type.filter_name
          json[index_key] ||= []
          json[index_key] << option_value.id
        end
      end

      json
    end

    # product_properties: [:translations, :property]
    # product_properties: [:translations, property: :translations ]
    def filterable_properties_for_es
      json = {}

      product_properties.includes(:property ).each do |pp|
        # data is empty somehow.
        next if !pp.property_id.present?
        next if !pp.property.filterable?

        json[pp.property.filter_name] = pp.id
      end

      json
    end

    def vendor_for_es_index
      {
        vendor_id: vendor&.id,
        vendor_slug: vendor&.slug,
        vendor_name: vendor&.name
      }
    end

    def index_data
      {}
    end

    def search_data
      # possible: Infinity
      discount = compare_at_price.present? && compare_at_price.to_f > 0 ? (100 * (compare_at_price.to_f - price.to_f) / compare_at_price.to_f).to_i : 0

      # possible: Infinity
      on_hand = (total_on_hand.infinite? ? nil : total_on_hand)

      all_variants = variants_including_master.pluck(:id, :sku)
      skus = all_variants.map(&:last).reject(&:blank?)

      es_fields = {
        id: id,
        name: name,
        product_slug: slug,
        description: description,
        active: available?,
        in_stock: in_stock?,
        price: price.to_f,
        compare_at_price: compare_at_price.to_f,
        discount_amount: discount,
        skus: skus,
        total_on_hand: on_hand,
        product_type: product_type,

        # boost user purchase
        purchaser_ids: purchasers.uniq.pluck(:id),

        # meta data
        created_at: created_at,
        updated_at: updated_at,

        # analytics
        impressions_count: impressions_count,
        conversions_count: conversions_count,
        whishedlists_count: whishedlists_count,
        review_rating: review_rating,
        vendor_rating: vendor_rating,

        # TODO: category, brand, industry
        taxon_ids: taxon_and_ancestors.map(&:id),
        taxon_names: taxon_and_ancestors.map(&:name)
      }

      es_fields.merge!(filterable_option_types_for_es_index)
      es_fields.merge!(filterable_properties_for_es)
      es_fields.merge!(vendor_for_es_index)
      es_fields.merge!(index_data)

      es_fields
    end
  end
end
