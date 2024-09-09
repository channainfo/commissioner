class AddSlugToSpreeCmCommissionerImports < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_imports, :slug, :string, if_not_exists: true
    add_index :cm_imports, :slug, unique: true
  end
end
