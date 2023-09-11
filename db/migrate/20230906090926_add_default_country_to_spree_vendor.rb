class AddDefaultCountryToSpreeVendor < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_vendors, :default_country, :int, if_not_exists: true
  end
end
