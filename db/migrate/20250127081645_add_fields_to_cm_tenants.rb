class AddFieldsToCmTenants < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:cm_tenants, :slug)
      add_column :cm_tenants, :slug, :string
      add_index :cm_tenants, :slug, unique: true
    end

    unless column_exists?(:cm_tenants, :description)
      add_column :cm_tenants, :description, :text
    end

    unless column_exists?(:cm_tenants, :state)
      add_column :cm_tenants, :state, :integer, default: 0
    end
  end
end
