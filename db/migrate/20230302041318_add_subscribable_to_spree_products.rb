class AddSubscribableToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :subscribable, :boolean, index: true, default: false, if_not_exists: true
  end
end
