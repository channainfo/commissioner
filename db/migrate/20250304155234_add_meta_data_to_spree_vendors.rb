class AddMetaDataToSpreeVendors < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_vendors, :meta_title, :string, if_not_exists: true
    add_column :spree_vendors, :meta_description, :text, if_not_exists: true
  end
end
