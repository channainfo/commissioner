class AddKycToSpreeVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_variants, :kyc, :integer, if_not_exists: true
  end
end
