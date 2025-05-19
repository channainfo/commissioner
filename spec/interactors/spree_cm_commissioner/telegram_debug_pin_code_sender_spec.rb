require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramDebugPinCodeSender do
  let(:store) { create(:store, name: 'Test Store') }

  context 'email' do
    let(:pin_code) { create(:pin_code, :with_email) }

    it 'sends email PIN code to Telegram channel' do
      allow(ENV).to receive(:fetch).with('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil).and_return('channel-id')

      expect_any_instance_of(Telegram::Bot::Client).to receive(:send_message).with(
        chat_id: 'channel-id',
        parse_mode: 'HTML',
        text: <<~TEXT.chomp
          <b>From: Test Store</b>
          <b>PIN CODE sent to #{pin_code.contact}</b>
          <code>#{pin_code.code}</code> is your login code
        TEXT
      )

      described_class.call(pin_code: pin_code, name: store.name)
    end
  end

  context 'phone' do
    let(:pin_code) { create(:pin_code, :with_number) }

    it 'sends phone PIN code to Telegram channel' do
      allow(ENV).to receive(:fetch).with('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil).and_return('channel-id')

      expect_any_instance_of(Telegram::Bot::Client).to receive(:send_message).with(
        chat_id: 'channel-id',
        parse_mode: 'HTML',
        text: <<~TEXT.chomp
          <b>From: Test Store</b>
          <b>PIN CODE sent to #{pin_code.contact}</b>
          <code>#{pin_code.code}</code> is your login code
        TEXT
      )

      described_class.call(pin_code: pin_code, name: store.name)
    end

    context 'with error_message' do
      it 'sends phone PIN code to Telegram channel' do
        allow(ENV).to receive(:fetch).with('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil).and_return('channel-id')

        expect_any_instance_of(Telegram::Bot::Client).to receive(:send_message).with(
          chat_id: 'channel-id',
          parse_mode: 'HTML',
          text: <<~TEXT.chomp
            <b>From: Test Store</b>
            <b>PIN CODE sent to #{pin_code.contact}</b>
            <code>#{pin_code.code}</code> is your login code
            ⚠️ Error: <code>{"message": { "sender": "Not a valid string." }}<code> ⚠️
          TEXT
        )

        described_class.call(pin_code: pin_code, name: store.name, error_message: '{"message": { "sender": "Not a valid string." }}')
      end
    end
  end
end
