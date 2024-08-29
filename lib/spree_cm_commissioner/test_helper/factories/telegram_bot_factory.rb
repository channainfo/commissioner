FactoryBot.define do
  factory :cm_telegram_bot, class: SpreeCmCommissioner::TelegramBot do
    token { '6441690414:AAFBpevRdBaRTXmalJR2vcSdPNzYoDnMEFk' }
    username { 'contigoasiabot' }
    start_photo { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*') }
    preferred_start_button_text { 'Start' }
    preferred_start_button_url { 'https://www.contigoasia.com' }
  end
end
