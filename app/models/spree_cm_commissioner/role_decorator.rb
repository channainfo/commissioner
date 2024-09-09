module SpreeCmCommissioner
  module RoleDecorator
    def self.prepended(base)
      base.has_many :role_permissions, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'

      base.accepts_nested_attributes_for :role_permissions, allow_destroy: true
    end
  end
end

Spree::Role.prepend SpreeCmCommissioner::RoleDecorator unless Spree::Role.included_modules.include?(SpreeCmCommissioner::RoleDecorator)
