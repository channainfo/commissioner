class AddPromotedBoolToSpreeCmCommissionerVendorPlaces < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vendor_places, :promoted, :boolean, default: false, if_not_exists: true
  end
end
