module SpreeCmCommissioner
  class Permission < SpreeCmCommissioner::Base
    has_many :role_permissions, class_name: 'SpreeCmCommissioner::RolePermission', dependent: :destroy

    def slug
      "#{entry}.#{action}"
    end
  end
end
