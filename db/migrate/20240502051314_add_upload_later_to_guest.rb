class AddUploadLaterToGuest < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :upload_later, :boolean, default: false, if_not_exists: true
  end
end
