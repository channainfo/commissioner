class ChangeImportTypeToIntegerInSpreeCmCommissionerImport < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:cm_imports, :import_type, :string)
      change_column :cm_imports, :import_type, :integer, using: 'import_type::integer'
    end
  end
end

