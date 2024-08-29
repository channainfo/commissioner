class AddPreferencesAndSecureTokenColumnsToCmTelegramBots < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_telegram_bots, :preferences, :text, if_not_exists: true
    add_column :cm_telegram_bots, :secure_token, :string, null: false, if_not_exists: true
    add_index :cm_telegram_bots, :secure_token, unique: true, if_not_exists: true
  end
end
