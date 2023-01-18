module Spree
  module VendorDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType

      base.has_many :photos, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPhoto'
      base.has_many :option_values, through: :products
      base.has_many :vendor_option_types, class_name: 'SpreeCmCommissioner::VendorOptionType'
      base.has_many :option_types, through: :vendor_option_types
      base.has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorLogo'

      # TODO: we will need searchkick later
      # base.searchkick(
      #   word_start: [:name],
      #   unscope: false,
      # ) unless base.respond_to?(:searchkick_index)

      # base.scope :search_import, lambda {
      #   includes(
      #     :option_values,
      #   )
      # }

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

      def update_total_inventory
        update(total_inventory: variants.pluck(:permanent_stock).sum)
      end

      def update_min_max_price
        update(min_price: Spree::Product.min_price(self), max_price: Spree::Product.max_price(self))
      end

      def update_location
        update(state_id: stock_locations.first&.state_id)
      end
    end
  end
end

Spree::Vendor.prepend(Spree::VendorDecorator)
