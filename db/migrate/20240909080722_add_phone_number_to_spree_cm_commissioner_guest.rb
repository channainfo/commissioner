class AddPhoneNumberToSpreeCmCommissionerGuest < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :phone_number, :string, limit: 50, if_not_exists: true
  end
end
