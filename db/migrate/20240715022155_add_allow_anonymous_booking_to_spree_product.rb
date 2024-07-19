class AddAllowAnonymousBookingToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products , :allow_anonymous_booking, :boolean, default: false, if_not_exists: true
  end
end
