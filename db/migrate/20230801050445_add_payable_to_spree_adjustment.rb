class AddPayableToSpreeAdjustment < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_adjustments, :payable, polymorphic: true, index: true, if_not_exists: true
  end
end
