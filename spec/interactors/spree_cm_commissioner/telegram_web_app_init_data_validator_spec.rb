require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramWebAppInitDataValidator do
  let(:bot_token) { '6453379064:AAF8ISKbrDljptn6r5lMRj2Ben_s_ASmnnE' }
  let(:wrong_bot_token) { 'invalid-bot-token' }

  describe '.call' do
    context 'inline web bot (eg. https://t.me/contigoasiabot)' do
      let(:telegram_init_data) { 'user=%7B%22id%22%3A1029000609%2C%22first_name%22%3A%22Spooky%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22theacontigo%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=6719130073186955468&chat_type=private&auth_date=1692617684&hash=9c467fcab396b22e3670698cbb3cc9e7e486ce224c72c993ae295507a29f67bd' }

      it 'verified that data is from Telegram' do
        context = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)
        expect(context.success?).to be true
      end

      it 'could not verify that data is from Telegram' do
        context = described_class.call(telegram_init_data: telegram_init_data, bot_token: wrong_bot_token)
        expect(context.success?).to be false
      end

      it 'decoded telegram data whether it verified or not' do
        context1 = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)
        context2 = described_class.call(telegram_init_data: telegram_init_data, bot_token: wrong_bot_token)

        expect(context1.decoded_telegram_init_data).to eq context2.decoded_telegram_init_data
        expect(context1.decoded_telegram_init_data).to eq ({
          "user"=>"{\"id\":1029000609,\"first_name\":\"Spooky\",\"last_name\":\"\",\"username\":\"theacontigo\",\"language_code\":\"en\",\"allows_write_to_pm\":true}",
          "chat_instance"=>"6719130073186955468",
          "chat_type"=>"private",
          "auth_date"=>"1692617684",
          "hash"=>"9c467fcab396b22e3670698cbb3cc9e7e486ce224c72c993ae295507a29f67bd"
        })
      end
    end

    context 'web bot (user open web bot via telegram link: https://t.me/contigoasiabot/contigo)' do
      let(:telegram_init_data) { 'query_id=AAGhTVU9AAAAAKFNVT3HP4z4&user=%7B%22id%22%3A1029000609%2C%22first_name%22%3A%22Spooky%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22theacontigo%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&auth_date=1692617748&hash=e8ac0a19b0ec35dcce16e0788115cbec1ec1e38fd30c60ca9459246d1c1450ea' }

      it 'verified that data is from Telegram' do
        context = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)

        expect(context.success?).to be true
      end

      it 'could not verify that data is from Telegram when input wrong bot token' do
        context = described_class.call(telegram_init_data: telegram_init_data, bot_token: wrong_bot_token)

        expect(context.success?).to be false
      end

      it 'decoded telegram data whether it verified or not' do
        context1 = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)
        context2 = described_class.call(telegram_init_data: telegram_init_data, bot_token: wrong_bot_token)

        expect(context1.decoded_telegram_init_data).to eq context2.decoded_telegram_init_data
        expect(context1.decoded_telegram_init_data).to eq ({
          "query_id"=>"AAGhTVU9AAAAAKFNVT3HP4z4",
          "user"=>"{\"id\":1029000609,\"first_name\":\"Spooky\",\"last_name\":\"\",\"username\":\"theacontigo\",\"language_code\":\"en\",\"allows_write_to_pm\":true}",
          "auth_date"=>"1692617748",
          "hash"=>"e8ac0a19b0ec35dcce16e0788115cbec1ec1e38fd30c60ca9459246d1c1450ea"
        })
      end
    end
  end
end