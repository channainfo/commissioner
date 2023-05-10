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

    has_many :orders, class_name: 'Spree::Order', through: :subscriptions

    has_one :latest_subscription, -> { order(created_at: :desc) }, class_name: 'SpreeCmCommissioner::Subscription'

    has_many :variants, class_name: 'Spree::Variant', through: :subscriptions
    has_many :active_variants, class_name: 'Spree::Variant', through: :active_subscriptions, source: :variant

    validates :sequence_number, presence: true, uniqueness: { scope: :vendor_id }
    validates :email, uniqueness: { scope: :vendor_id }, allow_blank: true
    validates :phone_number, uniqueness: { scope: :vendor_id }, allow_blank: true
    validates :number, presence: true, uniqueness: { scope: :vendor_id }

    acts_as_paranoid
    self.whitelisted_ransackable_attributes = %w[number intel_phone_number first_name last_name taxon_id]

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
  end
end
