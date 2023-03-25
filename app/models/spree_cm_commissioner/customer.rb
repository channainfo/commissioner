module SpreeCmCommissioner
  class Customer < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::PhoneNumberSanitizer

    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :user, class_name: 'Spree::User', optional: true

    has_many :subscriptions, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy
    has_many :active_subscriptions, -> { active }, class_name: 'SpreeCmCommissioner::Subscription', dependent: :destroy

    has_many :variants, class_name: 'Spree::Variant', through: :subscriptions
    has_many :active_variants, class_name: 'Spree::Variant', through: :active_subscriptions, source: :variant

    self.whitelisted_ransackable_attributes = %w[email intel_phone_number first_name last_name]
  end
end
