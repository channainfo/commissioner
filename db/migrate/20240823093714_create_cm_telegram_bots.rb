class CreateCmTelegramBots < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_telegram_bots, if_not_exists: true do |t|
      t.string :username, index: true
      t.string :token

      t.timestamps
    end
  end
end
