class AddPayableToSpreeAdjustment < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:spree_adjustments, :payable_type)
      add_reference :spree_adjustments, :payable, polymorphic: true, index: true
    end
  end
end
