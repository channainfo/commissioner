class CreateSpreeCmCommissionerIdCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_id_cards, if_not_exists: true do |t|
      t.integer :card_type, default: 0

      t.timestamps

      t.references :guest, foreign_key: { to_table: :cm_guests }
    end
  end
end
