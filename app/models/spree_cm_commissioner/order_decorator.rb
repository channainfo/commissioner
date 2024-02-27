module SpreeCmCommissioner
  module OrderDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer
      base.include SpreeCmCommissioner::OrderRequestable

      base.scope :subscription, -> { where.not(subscription_id: nil) }
      base.scope :paid, -> { where(payment_state: :paid) }

      base.scope :filter_by_request_state, lambda {
        where(state: :complete)
          .where.not(request_state: nil)
          .where.not(payment_state: :paid)
          .order(created_at: :desc)
      }

      base.before_create :link_by_phone_number
      base.before_create :associate_customer

      base.validates :promo_total, base::MONEY_VALIDATION

      base.validates :phone_number, presence: true, if: :require_phone_number
      base.has_one :invoice, dependent: :destroy, class_name: 'SpreeCmCommissioner::Invoice'

      base.belongs_to :subscription, class_name: 'SpreeCmCommissioner::Subscription', optional: true
      base.has_many :customer, class_name: 'SpreeCmCommissioner::Customer', through: :subscription
      base.has_many :taxon, class_name: 'Spree::Taxon', through: :customer
      base.has_many :vendors, through: :products, class_name: 'Spree::Vendor'
      base.has_many :taxons, through: :products, class_name: 'Spree::Taxon'

      base.delegate :customer, to: :subscription, allow_nil: true

      base.whitelisted_ransackable_associations |= %w[customer taxon payments]

      base.after_update :precalculate_conversion, if: -> { state_changed_to_complete? }

      def base.search_by_qr_data!(data)
        token = data.match(/^R\d{9,}-([A-Za-z0-9_\-]+)$/)&.captures

        raise ActiveRecord::RecordNotFound, "Couldn't find Spree::Order with QR data: #{data}" unless token

        find_by!(token: token)
      end
    end

    # override
    def after_resume
      super

      precalculate_conversion
    end

    # override
    def after_cancel
      super

      precalculate_conversion
    end

    def precalculate_conversion
      line_items.each do |item|
        SpreeCmCommissioner::ConversionPreCalculatorJob.perform_later(item.product_id)
      end
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

    def state_changed_to_complete?
      saved_change_to_state? && state == 'complete'
    end

    # required only in one case,
    # some of line_items are ecommerce & not digital.
    def delivery_required?
      contain_non_digital_ecommerce?
    end

    def contain_non_digital_ecommerce?
      line_items.select { |item| item.ecommerce? && !item.digital? }.size.positive?
    end

    # overrided not to send email yet to user if order needs confirmation
    # it will send after vendors accepted.
    def confirmation_delivered?
      confirmation_delivered || need_confirmation?
    end

    # overrided
    def payment_required?
      return false if need_confirmation?

      super
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

      default_payment_method = Spree::PaymentMethod::Check.available_on_back_end.first_or_create! do |method|
        method.name ||= 'Invoice'
        method.stores = [Spree::Store.default] if method.stores.empty?
      end

      payments.create!(
        payment_method: default_payment_method,
        amount: order_total_after_store_credit
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

    private

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
  end
end

if Spree::Order.included_modules.exclude?(SpreeCmCommissioner::OrderDecorator)
  # remove all promo_total validations
  Spree::Order._validators.reject! { |key, _| key == :promo_total }
  Spree::Order._validate_callbacks.each { |c| c.filter.attributes.delete(:promo_total) if c.filter.respond_to?(:attributes) }

  # prepend decorator will include new validations
  Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator)
end
