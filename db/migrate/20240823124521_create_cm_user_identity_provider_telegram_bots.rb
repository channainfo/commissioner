class CreateCmUserIdentityProviderTelegramBots < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_identity_provider_telegram_bots, if_not_exists: true do |t|
      t.references :telegram_bot, null: false, foreign_key: { to_table: :cm_telegram_bots }, index: { name: "index_user_identity_provider_tg_bots_on_tg_bot" }
      t.references :user_identity_provider, null: false, foreign_key: { to_table: :cm_user_identity_providers }, index: { name: "index_user_identity_provider_tg_bots_on_user_identity_provider" }

      t.datetime :last_sign_in_at

      t.timestamps
    end
  end
end
