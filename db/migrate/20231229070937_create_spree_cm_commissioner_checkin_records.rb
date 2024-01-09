class CreateSpreeCmCommissionerCheckinRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_checkin_records, if_not_exists: true do |t|
      t.integer :verification_state, default: 0
      t.datetime :confirmed_at
      t.integer :checkin_type, default: 0
      t.integer :entry_type, default: 0
      t.string :token, limit: 32
      t.integer :checkin_method, default: 0

      t.references :order, foreign_key: { to_table: 'spree_orders' }
      t.references :line_item, foreign_key: { to_table: 'spree_line_items' }
      t.references :guest, foreign_key: { to_table: 'cm_guests' }
      t.references :checkin_by, foreign_key: { to_table: 'spree_users' }

      t.timestamps
    end

    add_index :cm_checkin_records, :order_id, if_not_exists: true
    add_index :cm_checkin_records, :line_item_id, if_not_exists: true
    add_index :cm_checkin_records, :guest_id, if_not_exists: true
    add_index :cm_checkin_records, :checkin_by_id, if_not_exists: true
    add_index :cm_checkin_records, :token, if_not_exists: true
  end
end
