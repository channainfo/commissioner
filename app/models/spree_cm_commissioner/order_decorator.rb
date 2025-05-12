module SpreeCmCommissioner
  module OrderDecorator
    def self.prepended(base) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      base.include SpreeCmCommissioner::PhoneNumberSanitizer
      base.include SpreeCmCommissioner::OrderStateMachine

      base.scope :subscription, -> { where.not(subscription_id: nil) }
      base.scope :paid, -> { where(payment_state: :paid) }
      base.scope :complete_or_canceled, -> { complete.or(where(state: 'canceled')) }
      base.scope :payment, -> { incomplete.where(state: 'payment') }
      base.scope :archived, -> { where.not(archived_at: nil) }
      base.scope :not_archived, -> { where(archived_at: nil) }
      base.scope :without_user, -> { where(user_id: nil) }

      base.scope :filter_by_match_user_contact, lambda { |user|
        complete.where(
          '(email = :email OR intel_phone_number = :intel_phone_number) AND user_id IS NULL',
          email: user.email,
          intel_phone_number: user.intel_phone_number
        )
      }

      base.scope :filter_by_vendor, lambda { |vendor|
        joins(:line_items).where(spree_line_items: { vendor_id: vendor }).distinct
      }

      base.before_create :link_by_phone_number
      base.before_create :associate_customer
      base.before_create :set_tenant_id

      base.validates :promo_total, base::MONEY_VALIDATION
      base.validate :validate_channel_prefix, if: :channel_changed?
      base.validates :phone_number, presence: true, if: :require_phone_number

      base.has_one :invoice, dependent: :destroy, class_name: 'SpreeCmCommissioner::Invoice'
      base.has_one :customer, class_name: 'SpreeCmCommissioner::Customer', through: :subscription

      base.belongs_to :tenant, class_name: 'SpreeCmCommissioner::Tenant', optional: true
      base.belongs_to :subscription, class_name: 'SpreeCmCommissioner::Subscription', optional: true

      base.has_many :taxons, class_name: 'Spree::Taxon', through: :customer
      base.has_many :vendors, through: :products, class_name: 'Spree::Vendor'
      base.has_many :taxons, through: :products, class_name: 'Spree::Taxon'
      base.has_many :guests, through: :line_items, class_name: 'SpreeCmCommissioner::Guest'
      base.has_many :guest_card_classes, class_name: 'SpreeCmCommissioner::GuestCardClass', through: :variants

      base.delegate :customer, to: :user, allow_nil: true

      base.whitelisted_ransackable_associations |= %w[customer taxon payments guests invoice]
      base.whitelisted_ransackable_attributes |= %w[intel_phone_number phone_number email number state]

      def base.search_by_qr_data!(data)
        token = data.match(/^R\d{9,}-([A-Za-z0-9_\-]+)$/)&.captures

        raise ActiveRecord::RecordNotFound, "Couldn't find Spree::Order with QR data: #{data}" unless token

        find_by!(token: token)
      end
    end

    # override
    # spree use this method to check stock availability & consider whether :order can continue to next state.
    def insufficient_stock_lines
      checker = SpreeCmCommissioner::Stock::OrderAvailabilityChecker.new(self)
      checker.insufficient_stock_lines
    end

    def ticket_seller_user?
      return false if user.nil?

      user.has_spree_role?('ticket_seller')
    end

    # override
    def collect_payment_methods(store = nil)
      return super if user.blank?
      return super unless user.early_adopter?

      collect_payment_methods_for_early_adopter(store)
    end

    def collect_payment_methods_for_early_adopter(store = nil)
      store ||= self.store
      store.payment_methods.available_on_frontend_for_early_adopter.select { |pm| pm.available_for_order?(self) }
    end

    # override
    def delivery_required?
      line_items.any?(&:delivery_required?)
    end

    # overrided
    def payment_required?
      return false if need_confirmation?

      super
    end

    # overrided
    # add phone_number
    # trigger when update customer detail
    def associate_user!(user, override_email = true) # rubocop:disable Style/OptionalBooleanParameter
      self.user           = user
      self.email          = user.email if override_email
      self.phone_number   = user.phone_number if user.phone_number.present?
      self.created_by   ||= user
      self.bill_address ||= user.bill_address.try(:clone)
      self.ship_address ||= user.ship_address.try(:clone)

      changes = slice(:user_id, :email, :phone_number, :created_by_id, :bill_address_id, :ship_address_id)

      self.class.unscoped.where(id: self).update_all(changes) # rubocop:disable Rails/SkipsModelValidations
    end

    def mark_as_archive
      update(archived_at: Time.current)
    end

    # overrided
    # avoid raise error when source_id is nil.
    # https://github.com/channainfo/commissioner/pull/843
    def valid_promotion_ids
      all_adjustments.eligible.nonzero.promotion
                     .where.not(source_id: nil)
                     .map { |a| a.source.promotion_id }.uniq
    end

    # assume check is default payment method for subscription
    def create_default_payment_if_eligble
      return unless subscription?

      if covered_by_store_credit
        payment_method = Spree::PaymentMethod::StoreCredit.available_on_back_end.first_or_create! do |method|
          method.name ||= 'StoreCredit'
          method.stores = [Spree::Store.default] if method.stores.empty?
        end
        source_id = user.store_credit_ids.last
        source_type = 'Spree::StoreCredit'
      else
        payment_method = Spree::PaymentMethod::Check.available_on_back_end.first_or_create! do |method|
          method.name ||= 'Invoice'
          method.stores = [Spree::Store.default] if method.stores.empty?
        end
      end
      payments.create!(
        payment_method: payment_method,
        amount: total,
        source_id: source_id,
        source_type: source_type
      )
      Spree::Checkout::Advance.call(order: self)
    end

    def subscription?
      subscription.present?
    end

    def customer_address
      bill_address || ship_address
    end

    def order_completed?
      complete? && need_confirmation? == false
    end

    def generate_svg_qr
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 5,
        standalone: true,
        use_path: true,
        viewbox: '0 0 20 10'
      )
    end

    def generate_png_qr(size = 120)
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_png(
        bit_depth: 1,
        border_modules: 1,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 4,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: size
      )
    end

    def qr_data
      "#{number}-#{token}"
    end

    def display_outstanding_balance
      Spree::Money.new(outstanding_balance, currency: currency).to_s
    end

    private

    def unstock_inventory_in_redis!
      SpreeCmCommissioner::RedisStock::InventoryUpdater.new(line_item_ids).unstock!
    end

    def restock_inventory_in_redis!
      SpreeCmCommissioner::RedisStock::InventoryUpdater.new(line_item_ids).restock!
    end

    # override :spree_api
    def webhook_payload_body
      resource_serializer.new(
        self,
        include: included_relationships.reject { |e| %i[shipments state_changes].include?(e) }
      ).serializable_hash.to_json
    end

    def link_by_phone_number
      return if phone_number.present?

      self.phone_number = user.phone_number if user
    end

    def require_phone_number
      require_contact
    end

    # override
    def require_email
      require_contact
    end

    def require_contact
      return false if phone_number.present? || email.present?

      true unless new_record? || %w[cart address].include?(state)
    end

    def associate_customer
      return unless customer

      self.bill_address ||= customer.bill_address.try(:clone)
      self.ship_address ||= customer.ship_address.try(:clone)
    end

    def validate_channel_prefix
      allowed_prefixes = %w[spree google_form telegram]
      return if allowed_prefixes.any? { |prefix| channel&.start_with?(prefix) }

      errors.add(:channel, "must start with one of the following: #{allowed_prefixes.join(', ')}")
    end

    def set_tenant_id
      self.tenant_id = MultiTenant.current_tenant_id
    end
  end
end

if Spree::Order.included_modules.exclude?(SpreeCmCommissioner::OrderDecorator)
  # remove all promo_total validations
  Spree::Order._validators.reject! { |key, _| key == :promo_total }
  Spree::Order._validate_callbacks.each { |c| c.filter.attributes.delete(:promo_total) if c.filter.respond_to?(:attributes) }

  # prepend decorator will include new validations
  Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator)
end
