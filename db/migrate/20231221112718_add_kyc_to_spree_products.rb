class AddKycToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :kyc, :integer, default: 0, if_not_exists: true
  end
end
