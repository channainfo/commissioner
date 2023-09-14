class AddBranchIdToCmPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :branch_id, :integer
  end
end
