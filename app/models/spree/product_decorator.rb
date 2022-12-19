module Spree
  module ProductDecorator
    def self.prepended(base)
      base.has_many :master_option_types, -> { where(is_master: true).order(:position) }, 
        through: :product_option_types, source: :option_type

      base.has_many :option_types_excluding_master, -> { where(is_master: false).order(:position) }, 
        through: :product_option_types, source: :option_type

      base.has_many :option_types_including_master, -> { order(:position) }, through: :product_option_types

      base.has_many :option_values, through: :option_types
      base.has_many :prices_including_master, -> { order('spree_variants.position, spree_variants.id, currency') }, source: :prices, through: :variants_including_master

      base.scope  :min_price, -> (vendor) { joins(:prices_including_master).where(vendor_id: vendor.id).minimum('spree_prices.price').to_f }
      base.scope  :max_price, -> (vendor) { joins(:prices_including_master).where(vendor_id: vendor.id).maximum('spree_prices.price').to_f }

      base.after_commit :create_location
    end

    private

    def create_location
      location = vendor.stock_locations.first
      raise ("Missig state in stock location for vendorId: #{vendor.id}") if location&.state_id.nil?

      option_type = Spree::OptionType.find_or_create_by(name: 'location', presentation: 'Location', attr_type: 'state_selection')
      option_value = option_type.option_values.find_or_create_by(presentation: location.state_id, name: location.name)

      # append option type location to product
      self.option_types << option_type if option_type_ids.exclude?(option_type.id)

      # create option_value location to variants
      variants.each { |v|
        v.option_value_variants.find_or_create_by(option_value_id: option_value.id)
      }
    end
  end
end

Spree::Product.prepend(Spree::ProductDecorator)