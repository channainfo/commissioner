class MigrateGuestIdToPolymorphicInCmIdCards < ActiveRecord::Migration[7.0]
  def up
    add_reference :cm_id_cards, :id_cardable, polymorphic: true, index: true
  end

  def down
    remove_reference :cm_id_cards, :id_cardable, polymorphic: true, index: true
  end
end
