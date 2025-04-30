# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module SpreeCmCommissioner
  module ProductDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType
      base.include SpreeCmCommissioner::KycBitwise
      base.include SpreeCmCommissioner::Metafield
      base.include SpreeCmCommissioner::TenantUpdatable
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

      base.has_many :homepage_section_relatables,
                    class_name: 'SpreeCmCommissioner::HomepageSectionRelatable',
                    dependent: :destroy, as: :relatable

      # after finish purchase an order, user must complete these steps
      base.has_many :product_completion_steps, class_name: 'SpreeCmCommissioner::ProductCompletionStep', dependent: :destroy

      base.has_one :default_state, through: :vendor
      base.has_one :google_wallet, class_name: 'SpreeCmCommissioner::GoogleWallet', dependent: :destroy

      base.has_many :complete_line_items, through: :classifications, source: :line_items
      base.has_many :inventory_items, through: :variants

      base.has_many :product_places, class_name: 'SpreeCmCommissioner::ProductPlace', dependent: :destroy
      base.has_many :places, through: :product_places

      base.has_one :venue, -> { where(type: :venue) }, class_name: 'SpreeCmCommissioner::ProductPlace', dependent: :destroy

      base.accepts_nested_attributes_for :product_places, allow_destroy: true

      base.has_one :trip, class_name: 'SpreeCmCommissioner::Trip', dependent: :destroy

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

      base.validate :validate_event_taxons, if: -> { taxons.event.present? }

      base.validate :validate_product_date, if: -> { available_on.present? && discontinue_on.present? }

      base.validates :commission_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

      base.whitelisted_ransackable_attributes = %w[description name slug discontinue_on status vendor_id short_name route_type]

      base.after_update :update_variants_vendor_id, if: :saved_change_to_vendor_id?

      base.enum purchasable_on: { both: 0, web: 1, app: 2 }

      base.accepts_nested_attributes_for :trip, allow_destroy: true

      base.multi_tenant :tenant, class_name: 'SpreeCmCommissioner::Tenant'
      base.before_save :set_tenant
    end

    def associated_event
      taxons.event.first&.parent
    end

    def ticket_url
      "#{Spree::Store.default.formatted_url}/tickets/#{slug}"
    end

    private

    def set_tenant
      self.tenant_id = vendor&.tenant_id
    end

    def update_variants_vendor_id
      variants_including_master.find_each { |variant| variant.update!(vendor_id: vendor_id) }
    end

    def validate_event_taxons
      errors.add(:taxons, 'Event Taxon can\'t not be more than 1') if taxons.event.size > 1
      errors.add(:taxons, 'Must add event date to taxon') if taxons.event.first.from_date.nil? || taxons.event.first.to_date.nil?
    end

    def validate_product_date
      return unless discontinue_on < available_on

      errors.add(:discontinue_on, 'must be after the available on date')
    end
  end
end

Spree::Product.prepend(SpreeCmCommissioner::ProductDecorator) unless Spree::Product.included_modules.include?(SpreeCmCommissioner::ProductDecorator)
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
