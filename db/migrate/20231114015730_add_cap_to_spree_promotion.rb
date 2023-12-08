class AddCapToSpreePromotion < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_promotions, :cap, :float, if_not_exists: true
  end
end
