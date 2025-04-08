module SpreeCmCommissioner
  class RolePermissionsConstructor
    def initialize(params)
      @params = params[:role_permissions_attributes] || {}
    end

    def call
      construct_role_permissions
    end

    private

    def construct_role_permissions
      role_permissions_attributes = {}

      @params.each do |index, role_permission_attributes|
        role_permission_attributes = role_permission_attributes.to_h.symbolize_keys
        selected = role_permission_attributes.delete(:selected) == 'true'
        role_permission_persisted = role_permission_attributes.key?(:id)

        if role_permission_attributes[:permission_attributes]
          permission_attributes = role_permission_attributes[:permission_attributes].to_h.symbolize_keys
          permission_persisted = permission_attributes.key?(:id)

          if permission_persisted
            role_permission_attributes[:permission_id] = permission_attributes[:id]
            role_permission_attributes.delete(:permission_attributes)
          end
        end

        if selected
          role_permissions_attributes[index] = role_permission_attributes
        elsif role_permission_persisted
          role_permission_attributes[:_destroy] = 1
          role_permissions_attributes[index] = role_permission_attributes
        end
      end

      role_permissions_attributes
    end
  end
end
