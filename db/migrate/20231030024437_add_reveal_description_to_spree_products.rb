class AddRevealDescriptionToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :reveal_description, :boolean, default: false, if_not_exists: true
  end
end