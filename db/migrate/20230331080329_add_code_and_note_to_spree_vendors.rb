class AddCodeAndNoteToSpreeVendors < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_vendors, :code, :string, if_not_exists: true
    add_column :spree_vendors, :note, :text, if_not_exists: true
  end
end
