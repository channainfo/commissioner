class AddEventToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:spree_line_items, :event_id)
      add_reference :spree_line_items, :event, index: true
    end
  end
end
