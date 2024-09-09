class AddKycToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :kyc, :boolean, default: false, if_not_exists: true
  end
end
