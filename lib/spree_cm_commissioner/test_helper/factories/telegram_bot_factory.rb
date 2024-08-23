FactoryBot.define do
  factory :cm_telegram_bot, class: SpreeCmCommissioner::TelegramBot do
    token { '6441690414:AAFBpevRdBaRTXmalJR2vcSdPNzYoDnMEFk' }
    username { 'contigoasiabot' }
  end
end
