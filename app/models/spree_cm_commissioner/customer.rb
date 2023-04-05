module SpreeCmCommissioner
  class Customer < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::PhoneNumberSanitizer

    before_validation :generate_sequence_number, if: :sequence_number.nil?

    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :user, class_name: 'Spree::User', optional: true

    has_many :subscriptions, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy
    has_many :active_subscriptions, -> { active }, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy

    has_many :orders, class_name: 'Spree::Order', through: :subscriptions

    has_many :variants, class_name: 'Spree::Variant', through: :subscriptions
    has_many :active_variants, class_name: 'Spree::Variant', through: :active_subscriptions, source: :variant

    validates :sequence_number, presence: true, uniqueness: { scope: :vendor_id }

    self.whitelisted_ransackable_attributes = %w[email intel_phone_number first_name last_name]

    def generate_sequence_number
      last_customer = vendor.customers.last
      self.sequence_number = last_customer.present? ? last_customer.sequence_number.to_i + 1 : 1
    end

    def customer_number
      "#{vendor.code}-#{sequence_number.to_s.rjust(6, '0')}"
    end
  end
end
