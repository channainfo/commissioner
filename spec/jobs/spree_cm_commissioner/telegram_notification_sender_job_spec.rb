require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramNotificationSenderJob do
  let(:chat_id) { 123456 }
  let(:message) { 'Test message' }
  let(:parse_mode) { 'HTML' }

  it 'calls TelegramNotificationSender with the correct arguments' do
    expect(SpreeCmCommissioner::TelegramNotificationSender).to receive(:call).with(
      chat_id: chat_id,
      message: message,
      parse_mode: parse_mode
    )

    subject.perform(
      chat_id: chat_id,
      message: message,
      parse_mode: parse_mode
    )
  end

  it 'does not call TelegramNotificationSender when chat_id is nil' do
    expect(SpreeCmCommissioner::TelegramNotificationSender).not_to receive(:call)

    subject.perform(
      chat_id: nil,
      message: message,
      parse_mode: parse_mode
    )
  end
end
