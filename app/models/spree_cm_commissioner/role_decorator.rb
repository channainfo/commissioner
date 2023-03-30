module SpreeCmCommissioner
  module RoleDecorator
    attr_reader :user

    def self.prepended(base)
      base.has_many :role_permissions, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'

      base.accepts_nested_attributes_for :role_permissions, allow_destroy: true
    end

    def initialize(user, role, entry, action)
      @user = user
      @role = role
      @entry = entry
      @action = action
    end

    def authorize?
      return false if @user.nil?
      return false if @user.role.nil?
      return false if @user.access_group.nil?
      return false if @user.access_group.access[map_entry].nil?

      @user.access_group.access[map_entry][@action] == 1
    end

    def map_entry
      return @entry.to_s.tableize if @entry.class == Symbol || @entry.class == String || @entry.class == Class

      @entry.class.to_s.tableize
    end
  end
end

Spree::Role.prepend SpreeCmCommissioner::RoleDecorator unless Spree::Role.included_modules.include?(SpreeCmCommissioner::RoleDecorator)
