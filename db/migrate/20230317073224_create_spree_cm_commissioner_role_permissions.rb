class CreateSpreeCmCommissionerRolePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_role_permissions do |t|
      t.references :role, foreign_key: { to_table: :spree_roles }, index: true
      t.references :permission, foreign_key: { to_table: :cm_permissions }, index: true

      t.timestamps
    end
  end
end