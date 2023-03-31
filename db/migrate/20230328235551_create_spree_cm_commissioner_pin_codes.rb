class CreateSpreeCmCommissionerPinCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_pin_codes do |t|
      t.string      :code,                limit: 6
      t.string      :type,                limit: 60
      t.string      :contact,             limit: 100
      t.integer     :contact_type,        default: 0
      t.integer     :expires_in
      t.datetime    :expired_at
      t.integer     :number_of_attempt,   default: 0
      t.string      :token,               limit: 32
      
      t.timestamps
    end
  end
end
