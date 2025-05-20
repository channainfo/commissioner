module SpreeCmCommissioner
  class UserRolesAssigner
    attr_reader :user_id, :email, :role_ids, :vendor_id, :user

    def self.create(user_id: nil, email: nil, role_ids: nil, vendor_id: nil)
      new(user_id: user_id, email: email, role_ids: role_ids, vendor_id: vendor_id).create
    end

    def self.update(user_id: nil, email: nil, role_ids: nil, vendor_id: nil)
      new(user_id: user_id, email: email, role_ids: role_ids, vendor_id: vendor_id).update
    end

    def initialize(user_id: nil, email: nil, role_ids: nil, vendor_id: nil)
      @user_id = user_id
      @email = email
      @role_ids = role_ids
      @vendor_id = vendor_id
      @user = find_user
    end

    def create
      return { success: false, message: I18n.t('user_roles_assigner.user_not_found') } unless user
      return { success: false, message: I18n.t('user_roles_assigner.user_already_assigned') } if user.vendors.exists?(id: vendor_id)
      return { success: false, message: I18n.t('user_roles_assigner.roles_required') } if role_ids.blank?

      create_roles
      { success: true }
    end

    def update
      return { success: false, message: I18n.t('user_roles_assigner.roles_required') } if role_ids.blank?

      update_roles
      { success: true }
    end

    private

    def find_user
      return Spree::User.find_by(id: user_id) if user_id.present?
      return Spree::User.find_by(email: email) if email.present?

      nil
    end

    def users_role
      roles = Spree::Role.filter_by_vendor(vendor_id)
      user.role_users.where(role: roles)
    end

    def create_roles
      vendor = Spree::Vendor.find_by(id: vendor_id)
      user.vendors << vendor unless user.vendors.include?(vendor)
      role_ids.each { |role_id| users_role.find_or_create_by(role_id: role_id) }
    end

    def update_roles
      users_role.where.not(role_id: role_ids).destroy_all
      role_ids.each { |role_id| users_role.find_or_create_by(role_id: role_id) }
    end
  end
end
