module SpreeCmCommissioner
  class Tenant < SpreeCmCommissioner::Base
    extend FriendlyId
    friendly_id :name, use: :history

    has_many :vendors, class_name: 'Spree::Vendor'

    enum state: { enabled: 0, disabled: 1 }

    before_validation :generate_slug, if: -> { slug.blank? && name.present? }

    private

    def generate_slug
      self.slug = name.parameterize if slug.blank?
    end
  end
end
