class AddAllowSelfCheckInToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :allow_self_check_in, :boolean, default: false, if_not_exists: true
  end
end
