class CreateSpreePromotionRuleCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_customer_promotion_rules do |t|
      t.references :promotion_rule, index: true, if_not_exists: true
      t.references :customer, index: true, if_not_exists: true
      t.timestamps
    end
  end
end
