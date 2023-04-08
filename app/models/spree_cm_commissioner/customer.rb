module SpreeCmCommissioner
  class Customer < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::PhoneNumberSanitizer

    before_validation :generate_sequence_number, if: :sequence_number.nil?
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

    has_many :variants, class_name: 'Spree::Variant', through: :subscriptions
    has_many :active_variants, class_name: 'Spree::Variant', through: :active_subscriptions, source: :variant

    validates :sequence_number, presence: true, uniqueness: { scope: :vendor_id }
    validates :email, uniqueness: { scope: :vendor_id }, allow_blank: true
    validates :phone_number, uniqueness: { scope: :vendor_id }, allow_blank: true

    self.whitelisted_ransackable_attributes = %w[email intel_phone_number first_name last_name]

    accepts_nested_attributes_for :ship_address, :bill_address

    def generate_sequence_number
      return if sequence_number.present?

      last_customer = vendor.customers.last
      self.sequence_number = last_customer.present? ? last_customer.sequence_number.to_i + 1 : 1
    end

    def customer_number
      "#{vendor.code}-#{sequence_number.to_s.rjust(6, '0')}"
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
  end
end
