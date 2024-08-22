class CreateSpreeComCommissionerUserPaymentOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_payment_options, if_not_exists: true do |t|
      t.references :payment_method, foreign_key: { to_table: :spree_payment_methods }
      t.references :user
      
      t.index [:payment_method_id, :user_id], unique: true

      t.timestamps
    end
  end
end
