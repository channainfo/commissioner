module SpreeCmCommissioner
  class UserRolesAssigner < BaseInteractor
    delegate :user_id, :role_ids, to: :context

    def call
      context.fail!(message: I18n.t('user_roles_assigner.user_not_found')) unless user
      context.fail!(message: I18n.t('user_roles_assigner.roles_empty')) if role_ids.blank?
      update_roles
    end

    private

    def user
      @user ||= Spree::User.find_by(id: user_id)
    end

    def update_roles
      user.role_users.where.not(role_id: role_ids).destroy_all
      role_ids.each { |role_id| user.role_users.find_or_create_by(role_id: role_id) }
    end
  end
end
