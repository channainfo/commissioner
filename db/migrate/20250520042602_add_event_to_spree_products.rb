class AddEventToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:spree_products, :event_id)
      add_reference :spree_products, :event, index: true
    end
  end
end
