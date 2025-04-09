module SpreeCmCommissioner
  class RolePermissionsLoader
    attr_reader :role, :permissions_config, :role_permissions

    def initialize(role, permissions_config)
      @role = role
      @permissions_config = permissions_config
      @role_permissions = []
    end

    def call
      load_role_permissions
      role_permissions.uniq(&:slug)
    end

    private

    def load_role_permissions
      processed_entries = {}

      permissions_config[:grouped].each do |entry, groups|
        next if processed_entries[entry]

        groups.each do |group_name, details|
          next if details['actions'].empty?

          permission = find_or_initialize_permission(entry, group_name)
          role_permission = build_role_permission(permission)
          @role_permissions << role_permission
        end

        processed_entries[entry] = true
      end
    end

    def find_or_initialize_permission(entry, action)
      SpreeCmCommissioner::Permission.where(
        entry: entry,
        action: action
      ).first_or_initialize
    end

    def build_role_permission(permission)
      if @role.persisted? && permission.persisted?
        SpreeCmCommissioner::RolePermission.where(
          role: @role,
          permission: permission
        ).first_or_initialize
      else
        SpreeCmCommissioner::RolePermission.new(
          role: @role,
          permission: permission
        )
      end
    end
  end
end
