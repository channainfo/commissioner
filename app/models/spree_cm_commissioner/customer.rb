module SpreeCmCommissioner
  class Customer < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::PhoneNumberSanitizer

    belongs_to :vendor, class_name: 'Spree::Vendor'
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :user, class_name: 'Spree::User', optional: true

    has_many :subscriptions, class_name: 'SpreeCmCommissioner::Subscription', dependent: :nullify

    self.whitelisted_ransackable_attributes = %w[email intel_phone_number first_name last_name]
  end
end
