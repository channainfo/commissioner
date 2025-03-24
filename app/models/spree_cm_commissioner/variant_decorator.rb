module SpreeCmCommissioner
  module VariantDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType
      base.include SpreeCmCommissioner::ProductDelegation
      base.include SpreeCmCommissioner::VariantOptionsConcern

      base.after_commit :update_vendor_price
      base.validate     :validate_option_types
      base.before_save -> { self.track_inventory = false }, if: :subscribable?

      base.belongs_to :vendor, class_name: 'Spree::Vendor'

      base.has_many :taxons, class_name: 'Spree::Taxon', through: :product
      base.has_many :visible_option_values, lambda {
                                              joins(:option_type).where(spree_option_types: { hidden: false })
                                            }, through: :option_value_variants, source: :option_value

      base.has_many :video_on_demands, class_name: 'SpreeCmCommissioner::VideoOnDemand', dependent: :destroy
      base.has_many :complete_line_items, -> { complete }, class_name: 'Spree::LineItem'

      base.has_many :variant_guest_card_class, class_name: 'SpreeCmCommissioner::VariantGuestCardClass'
      base.has_many :guest_card_classes, class_name: 'SpreeCmCommissioner::GuestCardClass', through: :variant_guest_card_class

      base.has_many :inventory_items, class_name: 'SpreeCmCommissioner::InventoryItem'
      base.has_many :active_inventory_items, -> { active }, class_name: 'SpreeCmCommissioner::InventoryItem'

      base.scope :subscribable, -> { active.joins(:product).where(product: { subscribable: true, status: :active }) }
      base.scope :with_permanent_stock, -> { joins(:product).where(product: { product_type: base::PERMANENT_STOCK_PRODUCT_TYPES }) }
      base.scope :with_non_permanent_stock, -> { joins(:product).where.not(product: { product_type: base::PERMANENT_STOCK_PRODUCT_TYPES }) }

      base.has_one :trip,
                   class_name: 'SpreeCmCommissioner::Trip'
      base.accepts_nested_attributes_for :option_values
      base.after_commit :sync_trip, if: -> { product.product_type == 'transit' }
    end

    def delivery_required?
      delivery_option == 'delivery'
    end

    def non_digital_ecommerce?
      !digital? && ecommerce?
    end

    # override
    def discontinued?
      super || product.discontinued?
    end

    def event
      taxons.event.first
    end

    def default_inventory_item_exist?
      inventory_items.exists?(inventory_date: nil)
    end

    def create_default_non_permanent_inventory_item!(quantity_available: nil, max_capacity: nil)
      return if product_type.blank? # handle in case product not exist for variant.
      return unless should_track_inventory?
      return if default_inventory_item_exist?

      inventory_items.create!(
        product_type: product_type,
        quantity_available: [0, quantity_available || total_on_hand].max,
        max_capacity: [0, max_capacity || total_on_hand].max
      )
    end

    # override
    def options_text
      @options_text ||= Spree::Variants::VisableOptionsPresenter.new(self).to_sentence
    end

    def selected_option_value_ids
      option_value_variants.pluck(:option_value_id)
    end

    def display_variant
      display_sku = sku.split('-').join(' ')
      display_price = Spree::Money.new(price.to_i, currency: currency).to_s
      "#{display_sku} - #{display_price}"
    end

    def transit?
      product.product_type == 'transit'
    end

    # override
    def in_stock?
      available_quantity.positive?
    end

    # TODO: handle logic for inventory_item quantity_available, and max_capacity in a new issue
    def inventory_item_stock
      case product_type
      when 'event', 'ecommerce', 'accommodation'
        { quantity_available: stock_items.sum(:count_on_hand), max_capacity: 0 }
      when 'bus', 'transit'
        { quantity_available: product.trip.vehicle.number_of_seats, max_capacity: 0 }
      else
        {}
      end
    end

    private

    def total_purchases
      Spree::LineItem.complete.where(variant_id: id).sum(:quantity).to_i
    end

    def available_quantity
      stock_count = stock_items.sum(&:count_on_hand)
      return stock_count if delivery_required?

      stock_count - total_purchases
    end

    def update_vendor_price
      return unless vendor.present? && product&.product_type == vendor&.primary_product_type

      vendor.update(min_price: price) if price < vendor.min_price
      vendor.update(max_price: price) if price > vendor.max_price
    end

    def validate_option_types
      variant = self

      option_values.each do |option_value|
        option_type = option_value.option_type
        next if option_type.nil?

        if variant.is_master? && !option_type.product?
          message = I18n.t('variant.validation.option_type_is_not_product', option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message)
        end

        if !variant.is_master? && !option_type.variant?
          message = I18n.t('variant.validation.option_type_is_not_variant', option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message)
        end
      end
    end

    def sync_trip
      return unless product.product_type == 'transit'

      trip = SpreeCmCommissioner::Trip.find_or_initialize_by(variant_id: id)

      trip.assign_attributes(
        product_id: product_id,
        origin_id: options.origin,
        destination_id: options.destination,
        departure_time: options.departure_time,
        duration: options.total_duration_in_seconds,
        vehicle_id: options.vehicle
      )
      trip.save
    end
  end
end

if Spree::Variant.included_modules.exclude?(SpreeCmCommissioner::VariantDecorator)
  # spree_multi_vendor use :vendor method for assoication, we should use association (belongs_to :vendor) instead.
  #
  # problem with those methods is that it store value in memeory,
  # even we call variant.reload, the method value is no being reload.
  SpreeMultiVendor::Spree::VariantDecorator.remove_method :vendor if SpreeMultiVendor::Spree::VariantDecorator.method_defined?(:vendor)
  SpreeMultiVendor::Spree::VariantDecorator.remove_method :vendor_id if SpreeMultiVendor::Spree::VariantDecorator.method_defined?(:vendor_id)

  Spree::Variant.prepend(SpreeCmCommissioner::VariantDecorator)
end
