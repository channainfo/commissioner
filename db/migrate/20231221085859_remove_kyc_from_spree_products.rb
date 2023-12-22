class RemoveKycFromSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:spree_products, :kyc)
      remove_column :spree_products, :kyc, :boolean
    end
  end
end
