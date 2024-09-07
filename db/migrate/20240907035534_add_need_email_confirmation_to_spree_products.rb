class AddNeedEmailConfirmationToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :need_email_confirmation, :boolean, default: true, if_not_exists: true
  end
end
