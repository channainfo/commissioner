class AddDynamicKycToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:spree_products, :dynamic_kyc)
      add_column :spree_products, :dynamic_kyc, :jsonb, default: {}
    end
  end
end
