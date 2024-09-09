require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderCompleteTelegramSender do
  describe '#call' do
    context 'when order is not associated with user' do
      let(:order) { create(:completed_order_with_totals, user: nil) }

      it 'return fail' do
        context = described_class.call(order: order)

        expect(context.success?).to be false
        expect(context.message).to eq 'User must be present'
      end
    end

    context 'when order is associated with a user but user is not connected to telegram' do
      let(:user) { create(:user) }
      let(:order) { create(:completed_order_with_totals, user: user) }

      it 'return fail' do
        context = described_class.call(order: order)

        expect(context.success?).to be false
        expect(context.message).to eq 'User is not connected to Telegram'
      end
    end

    context 'when order is associated with a user & user is connected to Telegram', :vcr do
      let!(:telegram_bot) { create(:cm_telegram_bot, token: 'this-is-bot-token') }
      let!(:provider1) { create(:user_identity_provider, user: user, identity_type: :telegram, sub: '734348432', telegram_bots: [telegram_bot]) }
      let!(:provider2) { create(:user_identity_provider, user: user, identity_type: :google) }

      let(:user) { create(:user) }
      let(:order) { create(:completed_order_with_totals, user: user) }

      it 'send message to provider chat ID' do
        expect(provider1.telegram_chat_id).to eq '734348432'
        expect(provider2.telegram_chat_id).to eq nil

        expect_any_instance_of(described_class).to receive(:send).with(telegram_bot.token, '734348432').once.and_call_original
        expect_any_instance_of(::Telegram::Bot::Client).to receive(:send_message).once.and_call_original

        context = described_class.call(order: order)
        expect(context.success?).to be true
      end
    end
  end
end