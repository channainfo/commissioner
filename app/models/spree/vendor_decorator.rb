module Spree
  module VendorDecorator
    def self.prepended(base)
      base.has_many :photos, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPhoto'
      base.has_many :option_values, through: :products
      base.has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorLogo'

      # if base.method_defined?(:whitelisted_ransackable_associations)
      #   if base.whitelisted_ransackable_associations
      #     base.whitelisted_ransackable_associations |= %w[option_values]
      #   else
      #     base.whitelisted_ransackable_associations = %w[option_values]
      #   end
      # end

      base.searchkick(
        word_start: [:name],
        unscope: false,
      ) unless base.respond_to?(:searchkick_index)

      base.scope :search_import, lambda {
        includes(
          :option_values,
        )
      }

      def search_data
        # option_values_presentation
        presentations = option_values.pluck(:presentation).uniq
        json = {
          id: id,
          name: name,
          slug: slug,
          active: active?,
          min_price: min_price,
          max_price: max_price,
          created_at: created_at,
          updated_at: updated_at,
          presentation: presentations,
        }
        json
      end

      def base.search_fields
        [:name]
      end


      # Searchkick can't be reinitialized, this method allow to change options without it
      # ex add_searchkick_option { settings: { "index.mapping.total_fields.limit": 2000 } }
      def base.add_searchkick_option(option)
        base.class_variable_set(:@@searchkick_options, base.searchkick_options.deep_merge(option))
      end

      def index_data
        {}
      end
    end
  end
end

Spree::Vendor.prepend(Spree::VendorDecorator)
