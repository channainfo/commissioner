class AddTaxonIdToCheckIns < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_check_ins, :event_id, :integer, if_not_exists: true
  end
end
