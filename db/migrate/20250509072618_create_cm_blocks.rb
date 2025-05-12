class CreateCmBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_blocks do |t|
      t.integer :section_id
      t.string :label
      t.integer :status
      t.integer :block_type
      t.integer :row_index
      t.integer :column_index

      t.timestamps
    end
  end
end
