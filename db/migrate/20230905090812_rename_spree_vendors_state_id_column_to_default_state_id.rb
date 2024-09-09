class RenameSpreeVendorsStateIdColumnToDefaultStateId < ActiveRecord::Migration[7.0]
  def change
    rename_column :spree_vendors, :state_id, :default_state_id
  end
end
