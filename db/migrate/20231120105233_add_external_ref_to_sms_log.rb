class AddExternalRefToSmsLog < ActiveRecord::Migration[7.0]
  def change
    # UUID
    add_column :cm_sms_logs, :external_ref, :string, :limit => 36, if_not_exists: true
  end
end
