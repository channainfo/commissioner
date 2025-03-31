module SpreeCmCommissioner
  module RoleDecorator
    def self.prepended(base)
      base.has_many :role_permissions, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'

      base.belongs_to :vendor, optional: true

      base.scope :non_vendor, -> { where(vendor_id: nil) }

      base.accepts_nested_attributes_for :role_permissions, allow_destroy: true

      base._validators.reject! { |key, _| key == :name }
      base._validate_callbacks.each { |c| c.filter.attributes.delete(:name) if c.filter.respond_to?(:attributes) }

      base.validates :name, uniqueness: { scope: :vendor_id, allow_blank: true }
    end
  end
end

Spree::Role.prepend SpreeCmCommissioner::RoleDecorator unless Spree::Role.included_modules.include?(SpreeCmCommissioner::RoleDecorator)
