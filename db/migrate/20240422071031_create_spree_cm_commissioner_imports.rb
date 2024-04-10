class CreateSpreeCmCommissionerImports < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_imports do |t|
      t.string :name
      t.string :import_type
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
