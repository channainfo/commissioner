module Spree
  module VendorDecorator
    def self.prepended(base)
      base.belongs_to :primary_product_type, class_name: 'SpreeCmCommissioner::ProductType', foreign_key: 'primary_product_type_id'

      base.has_many :photos, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPhoto'
      base.has_many :option_values, through: :products
      base.has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorLogo'

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

      def index_data
        {}
      end
    end
  end
end

Spree::Vendor.prepend(Spree::VendorDecorator)
