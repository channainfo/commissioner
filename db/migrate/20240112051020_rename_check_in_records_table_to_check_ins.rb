class RenameCheckInRecordsTableToCheckIns < ActiveRecord::Migration[7.0]
  def change
    rename_table :cm_check_in_records, :cm_check_ins
  end
end
