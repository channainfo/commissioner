class AddForeignKeyToSpreeUserTenantId < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:spree_users, :tenant_id)
      unless foreign_key_exists?(:spree_users, column: :tenant_id)
        add_foreign_key :spree_users, :cm_tenants, column: :tenant_id
      end
    end
  end

  private

  def foreign_key_exists?(table, column:)
    foreign_keys(table).any? { |fk| fk.column == column.to_s }
  end
end
