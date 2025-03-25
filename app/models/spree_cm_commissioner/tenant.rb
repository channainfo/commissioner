module SpreeCmCommissioner
  class Tenant < SpreeCmCommissioner::Base
    extend FriendlyId
    friendly_id :name, use: :history

    has_many :vendors, class_name: 'Spree::Vendor', inverse_of: :tenant
    has_many :orders, class_name: 'Spree::Order', inverse_of: :tenant
    has_many :tenant_payment_methods, class_name: 'Spree::PaymentMethod',
                                      through: :vendors,
                                      source: :payment_methods

    enum state: { enabled: 0, disabled: 1 }

    before_validation :generate_slug, if: -> { slug.blank? && name.present? }

    private

    def generate_slug
      self.slug = name.parameterize if slug.blank?
    end
  end
end
