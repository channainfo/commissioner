class AddRequestStateToSpreeOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_orders, :request_state, :string, if_not_exists: true
  end
end
