module SpreeCmCommissioner
  class Customer < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::PhoneNumberSanitizer

    before_validation :generate_sequence_number, if: -> { sequence_number.nil? }
    before_validation :assign_number, if: -> { number.nil? }
    before_validation :clone_billing_address, if: :use_billing?

    attr_accessor :use_billing

    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :user, class_name: 'Spree::User', optional: true

    belongs_to :bill_address, class_name: 'Spree::Address',
                              optional: true
    alias_attribute :billing_address, :bill_address

    belongs_to :ship_address, class_name: 'Spree::Address',
                              optional: true
    alias_attribute :shipping_address, :ship_address

    has_many :subscriptions, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy
    has_many :active_subscriptions, -> { active }, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy
    has_many :suspended_subscriptions, -> { suspended }, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy

    has_many :orders, class_name: 'Spree::Order', through: :subscriptions

    has_one :latest_subscription, -> { order(created_at: :desc) }, class_name: 'SpreeCmCommissioner::Subscription'

    has_many :variants, class_name: 'Spree::Variant', through: :subscriptions
    has_many :active_variants, class_name: 'Spree::Variant', through: :active_subscriptions, source: :variant

    validates :sequence_number, presence: true, uniqueness: { scope: :vendor_id }
    validates :email, uniqueness: { scope: :vendor_id }, allow_blank: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :phone_number, uniqueness: { scope: :vendor_id }, allow_blank: true, unless: -> { Spree::Store.default.code.include?('billing') }
    validates :number, presence: true, uniqueness: { scope: :vendor_id }

    validate :billing_customer_attributes

    acts_as_paranoid
    self.whitelisted_ransackable_attributes = %w[number phone_number first_name last_name taxon_id sequence_number]

    accepts_nested_attributes_for :ship_address, :bill_address

    def generate_sequence_number
      return if sequence_number.present?

      last_customer = vendor.customers.last
      self.sequence_number = last_customer.present? ? last_customer.sequence_number.to_i + 1 : 1
    end

    def customer_number
      "#{vendor.code}-#{sequence_number.to_s.rjust(6, '0')}"
    end

    def assign_number
      self.number = customer_number
    end

    def update_number
      update(number: customer_number)
    end

    def use_billing?
      use_billing.in?([true, 'true', '1'])
    end

    def clone_billing_address
      if bill_address && ship_address.nil?
        self.ship_address = bill_address.clone
      else
        ship_address.attributes = bill_address.attributes.except('id', 'updated_at', 'created_at')
      end
      true
    end

    def overdue_subscriptions
      overdue_id = query_builder.where('li.due_date < ?', Time.zone.today)
                                .where.not("o.payment_state = 'paid' or o.payment_state = 'failed'")
                                .where(customer_id: id).first&.id
      return orders.where(subscription_id: overdue_id).first unless overdue_id.nil?

      'none'
    end

    def query_builder
      SpreeCmCommissioner::Subscription.joins('INNER JOIN spree_orders as o ON o.subscription_id = cm_subscriptions.id')
                                       .joins('INNER JOIN spree_line_items as li ON li.order_id = o.id ')
    end

    def subscribable_variants
      vendor.variants
            .joins('INNER JOIN spree_products as p ON p.id = spree_variants.product_id AND p.subscribable = TRUE')
            .joins('INNER JOIN spree_products_taxons as pt ON pt.product_id = p.id')
            .joins("INNER JOIN cm_customers as c on c.taxon_id = pt.taxon_id AND c.id = #{id}")
            .where('spree_variants.is_master = FALSE AND spree_variants.deleted_at IS NULL')
    end

    def fullname
      "#{first_name} #{last_name}"
    end

    def billing_customer_attributes
      return unless Spree::Store.default.code.include?('billing')

      errors.add(:base, :owner_name_cant_be_blank) if last_name.blank?
      errors.add(:base, :taxon_cant_be_blank) if taxon.blank?
      errors.add(:base, :phone_number_cant_be_blank) if phone_number.blank?
      errors.add(:base, :quantity_cant_be_less_than_or_equal_to_zero) if quantity <= 0
    end
  end
end
