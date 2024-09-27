class AddTemplateGuestIdToSpreeCmCommissionerGuest < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_guests, :template_guest, foreign_key: { to_table: :cm_template_guests }, index: true, if_not_exists: true
  end
end
