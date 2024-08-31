require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramStartMessageSender do
  describe '.call', :vcr do
    let!(:telegram_bot) { create(:cm_telegram_bot, token: 'this-is-bot-token') }

    it 'send photo to chat id' do
      expect_any_instance_of(::Telegram::Bot::Client).to receive(:send_photo).once.and_call_original

      context = described_class.call(
        chat_id: '734348432',
        telegram_bot: telegram_bot
      )

      expect(context.success?).to be true
    end
  end
end
