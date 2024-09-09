class AddPayableToSpreePayment < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_payments, :payable, polymorphic: true, index: true, if_not_exists: true
  end
end
