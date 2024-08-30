require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramStartMessageSenderJob do
  let(:chat_id) { 123456 }
  let(:telegram_bot_id) { 1 }

  let(:telegram_bot) { create(:cm_telegram_bot) }

  it 'calls TelegramNotificationSender with the correct arguments' do
    allow_any_instance_of(SpreeCmCommissioner::TelegramBot).to receive(:find).with(telegram_bot_id).and_return(telegram_bot)

    expect(SpreeCmCommissioner::TelegramStartMessageSender).to receive(:call).with(
      chat_id: chat_id,
      telegram_bot: telegram_bot
    )

    subject.perform(
      chat_id: chat_id,
      telegram_bot_id: telegram_bot_id
    )
  end
end
