module SpreeCmCommissioner
  module ProductDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType
      base.include SpreeCmCommissioner::RouteType

      base.has_many :variant_kind_option_types, -> { where(kind: :variant).order(:position) },
                    through: :product_option_types, source: :option_type

      base.has_many :product_kind_option_types, -> { where(kind: :product).order(:position) },
                    through: :product_option_types, source: :option_type

      base.has_many :promoted_option_types, -> { where(promoted: true).order(:position) },
                    through: :product_option_types, source: :option_type

      base.has_many :option_values, through: :option_types
      base.has_many :prices_including_master, lambda {
                                                order('spree_variants.position, spree_variants.id, currency')
                                              }, source: :prices, through: :variants_including_master

      base.has_one :default_state, through: :vendor
      base.has_one :trip_detail, class_name: 'SpreeCmCommissioner::TripDetail', dependent: :destroy

      base.scope :min_price, lambda { |vendor|
        joins(:prices_including_master)
          .where(vendor_id: vendor.id, product_type: vendor.primary_product_type)
          .minimum('spree_prices.price').to_f
      }

      base.scope :max_price, lambda { |vendor|
        joins(:prices_including_master)
          .where(vendor_id: vendor.id, product_type: vendor.primary_product_type)
          .maximum('spree_prices.price').to_f
      }
      base.scope :subscribable, -> { where(subscribable: 1) }

      base.whitelisted_ransackable_attributes |= %w[short_name route_type]

      base.accepts_nested_attributes_for :trip_detail, allow_destroy: true
    end
  end
end

Spree::Product.prepend(SpreeCmCommissioner::ProductDecorator) unless Spree::Product.included_modules.include?(SpreeCmCommissioner::ProductDecorator)
