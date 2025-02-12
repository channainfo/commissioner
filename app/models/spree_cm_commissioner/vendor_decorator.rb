# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module SpreeCmCommissioner
  module VendorDecorator
    STAR_RATING = [0, 1, 2, 3, 4, 5].freeze

    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType
      base.include SpreeCmCommissioner::VendorPromotable
      base.include SpreeCmCommissioner::VendorPreference

      base.attr_accessor :service_availabilities

      base.store :preferences, accessors: %i[account_name account_number penalty_rate penalty_label six_months_discount twelve_months_discount]

      base.before_save :generate_code, if: :code.nil?

      base.has_many :photos, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPhoto'
      base.has_many :option_values, through: :products
      base.has_many :vendor_option_types, class_name: 'SpreeCmCommissioner::VendorOptionType'
      base.has_many :option_value_vendors, class_name: 'SpreeCmCommissioner::OptionValueVendor'
      base.has_many :option_types, through: :vendor_option_types
      base.has_many :nearby_places, -> { order(position: :asc) }, class_name: 'SpreeCmCommissioner::VendorPlace', dependent: :destroy

      base.has_many :stock_items, through: :variants, class_name: 'Spree::StockItem'

      base.has_many :taxon_vendors, class_name: 'SpreeCmCommissioner::TaxonVendor'
      base.has_many :taxons, through: :taxon_vendors

      base.has_many :promoted_option_types, -> { where(promoted: true).order(:position) },
                    through: :vendor_option_types, source: :option_type

      base.has_many :vendor_kind_option_types, -> { where(kind: :vendor).order(:position) },
                    through: :vendor_option_types, source: :option_type

      base.has_many :vendor_kind_option_values,
                    through: :option_value_vendors, source: :option_value

      base.has_many :branches, class_name: 'SpreeCmCommissioner::Branch'
      base.has_many :stops, class_name: 'SpreeCmCommissioner::Stop'

      base.has_many :places,
                    through: :nearby_places, source: :place, class_name: 'SpreeCmCommissioner::Place'

      base.has_many :vendor_stops, class_name: 'SpreeCmCommissioner::VendorStop', dependent: :destroy
      base.has_many :boarding_points, -> { where(cm_vendor_stops: { stop_type: 0 }) },
                    through: :vendor_stops, source: :stop, class_name: 'Spree::Taxon'
      base.has_many :drop_off_points, -> { where(cm_vendor_stops: { stop_type: 1 }) },
                    through: :vendor_stops, source: :stop, class_name: 'Spree::Taxon'

      base.has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorLogo'
      base.has_one  :payment_qrcode, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPaymentQrcode'
      base.has_one  :web_promotion_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorWebPromotionBanner'
      base.has_one  :app_promotion_banner, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorAppPromotionBanner'
      base.has_one  :stock_location, -> { where(active: true) }, class_name: 'Spree::StockLocation', dependent: :destroy

      base.belongs_to :default_state, class_name: 'Spree::State', inverse_of: :vendors
      base.multi_tenant :tenant, class_name: 'SpreeCmCommissioner::Tenant'

      base.delegate :lat, :lon, to: :stock_location, allow_nil: true

      base.after_save :update_state_total_inventory, if: :saved_change_to_total_inventory?
      base.after_save :update_customer_numbers, if: :saved_change_to_code?

      base.has_many :promoted_option_values, -> { joins(:option_type).where('option_type.promoted' => true) },
                    through: :option_value_vendors, source: :option_value

      base.accepts_nested_attributes_for :nearby_places, allow_destroy: true

      base.has_many :service_calendars, as: :calendarable, dependent: :destroy, class_name: 'SpreeCmCommissioner::ServiceCalendar'

      base.has_many :customers, class_name: 'SpreeCmCommissioner::Customer', dependent: :destroy
      base.has_many :invoices, class_name: 'SpreeCmCommissioner::Invoice', dependent: :destroy
      base.has_many :subscriptions, through: :customers, class_name: 'SpreeCmCommissioner::Subscription'
      base.has_many :subscription_orders, through: :subscriptions, class_name: 'Spree::Order', source: :orders

      base.has_many :homepage_section_relatables,
                    class_name: 'SpreeCmCommissioner::HomepageSectionRelatable',
                    dependent: :destroy, inverse_of: :relatable

      base.has_many :vehicle_types, class_name: 'SpreeCmCommissioner::VehicleType', dependent: :destroy
      base.has_many :vehicles, through: :vehicle_types, class_name: 'SpreeCmCommissioner::Vehicle', dependent: :destroy

      base.validates :account_name, :account_number, presence: true, if: lambda {
                                                                           payment_qrcode.present? && Spree::Store.default.code.include?('billing')
                                                                         }

      base.validates :commission_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

      def base.by_vendor_id!(vendor_id)
        if vendor_id.to_s =~ /^\d+$/
          find(vendor_id)
        else
          find_by!(slug: vendor_id)
        end
      end

      # TODO: we will need searchkick later
      # unless Rails.env.test?
      #   base.searchkick(
      #     word_start: [:name],
      #     unscope: false,
      #   ) unless base.respond_to?(:searchkick_index)

      #   base.scope :search_import, lambda {
      #     includes(
      #       :option_values,
      #     )
      #   }
      # end

      # Override tenant immutability to allow clearing tenant_id
      def tenant_id=(new_tenant_id)
        self[:tenant_id] = new_tenant_id
      end

      extend Spree::DisplayMoney
      money_methods :min_price, :max_price

      def update_customer_numbers
        customers.each(&:update_number)
      end

      def selected_place_references
        places.pluck(:reference)
      end

      def search_data
        # option_values_presentation
        presentations = option_values.pluck(:presentation).uniq
        {
          id: id,
          name: name,
          slug: slug,
          active: active?,
          min_price: min_price,
          max_price: max_price,
          created_at: created_at,
          updated_at: updated_at,
          presentation: presentations
        }
      end

      def base.search_fields
        [:name]
      end

      def index_data
        {}
      end

      def update_total_inventory
        update(total_inventory: stock_items.pluck(:count_on_hand).sum)
      end

      def update_min_max_price
        min_price = Spree::Product.min_price(self)
        max_price = Spree::Product.max_price(self)
        min_price = max_price if min_price.zero?

        update(min_price: min_price, max_price: max_price)
      end

      def update_location
        update(default_state_id: stock_locations.first&.state_id)
      end

      def update_state_total_inventory
        SpreeCmCommissioner::StateJob.perform_later(default_state_id) unless default_state_id.nil?
      end
    end

    def selected_option_value_vendors_ids
      option_value_vendors.pluck(:option_value_id)
    end

    def generate_code
      self.code = (code.presence || name[0, 3].upcase)
    end
  end
end

Spree::Vendor.prepend(SpreeCmCommissioner::VendorDecorator) unless Spree::Vendor.included_modules.include?(SpreeCmCommissioner::VendorDecorator)

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
