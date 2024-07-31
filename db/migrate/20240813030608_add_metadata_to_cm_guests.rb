class AddMetadataToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :public_metadata, :jsonb
    add_column :cm_guests, :private_metadata, :jsonb
  end
end
