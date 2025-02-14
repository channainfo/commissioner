class AddRequiredSelfCheckInLocationToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :required_self_check_in_location, :boolean, default: false, if_not_exists: true
  end
end
