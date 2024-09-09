class AddCheckInAbleToCheckIns < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_check_ins, :checkinable, polymorphic: true, null: true
  end
end
