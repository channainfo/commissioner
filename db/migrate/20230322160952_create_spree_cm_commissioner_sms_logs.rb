class CreateSpreeCmCommissionerSmsLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_sms_logs do |t|
      t.string :from_number
      t.string :to_number
      t.string :body
      t.string :adapter_name
      t.string :error
      t.integer :status, default: 0
      
      t.timestamps
    end
    
    add_index :cm_sms_logs, :to_number
  end
end
