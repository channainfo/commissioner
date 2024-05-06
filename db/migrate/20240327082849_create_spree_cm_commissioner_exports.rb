class CreateSpreeCmCommissionerExports < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_exports do |t|
      t.string :name
      t.string :file_name
      t.string :file_path
      t.string :export_type
      t.datetime :started_at
      t.integer :status, default: 0
      t.string :uuid
      t.text :preferences
      t.timestamps
    end
  end
end
