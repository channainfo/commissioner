class CreateSpreeCmCommissionerGuestOccupationPromotionRules < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_guest_occupation_promotion_rules, if_not_exists: true do |t|

      t.references :occupation, foreign_key: { to_table: :spree_taxons }
      t.references :promotion_rule

      t.timestamps
    end
  end
end
