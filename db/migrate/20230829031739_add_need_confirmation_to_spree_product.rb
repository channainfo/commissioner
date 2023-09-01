class AddNeedConfirmationToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :need_confirmation, :boolean, default: false, if_not_exists: true
  end
end
