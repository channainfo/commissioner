module SpreeCmCommissioner
  module RoleDecorator
    def self.prepended(base)
      base.has_many :role_permissions, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'

      base.belongs_to :vendor, optional: true

      base.scope :non_vendor, -> { where(vendor_id: nil) }
      base.scope :filter_by_vendor, lambda { |vendor|
        where(vendor_id: vendor)
      }

      base.accepts_nested_attributes_for :role_permissions, allow_destroy: true

      base.before_validation :generate_unique_name, if: -> { vendor_id.present? }

      base.validates :presentation, uniqueness: { scope: :vendor_id }, presence: true, if: -> { vendor_id.present? }
    end

    def generate_unique_name
      return if name.present?
      return if presentation.blank?

      self.name = "#{vendor.slug}-#{presentation.downcase.parameterize(separator: '-')}"
    end
  end
end

Spree::Role.prepend SpreeCmCommissioner::RoleDecorator unless Spree::Role.included_modules.include?(SpreeCmCommissioner::RoleDecorator)
