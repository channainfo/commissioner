class RenameSpreeLineItemAcceptedByRejectedByColumnToAccepterRejecterId < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:spree_line_items, :accepted_by_id)
      rename_column :spree_line_items, :accepted_by_id, :accepter_id
    end

    if column_exists?(:spree_line_items, :rejected_by_id)
      rename_column :spree_line_items, :rejected_by_id, :rejecter_id
    end
  end
end
