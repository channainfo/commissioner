class AddShortDescriptionToSpreeVendor < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :short_description, :text, if_not_exists: true
  end
end
