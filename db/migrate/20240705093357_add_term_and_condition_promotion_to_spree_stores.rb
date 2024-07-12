class AddTermAndConditionPromotionToSpreeStores < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stores, :term_and_condition_promotion, :text, if_not_exists: true
  end
end
