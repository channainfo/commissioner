class RemoveGenderDefaultValueFromGuest < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:cm_guests, :gender)
      change_column_default(:cm_guests, :gender, from: 0, to: nil)
    end
  end
end
