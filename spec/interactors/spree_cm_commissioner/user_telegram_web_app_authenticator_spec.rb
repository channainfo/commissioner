require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserTelegramWebAppAuthenticator do
  let(:valid_bot_token) { '6453379064:AAF8ISKbrDljptn6r5lMRj2Ben_s_ASmnnE' }
  let(:invalid_bot_token) { 'invalid-bot-token' }
  let(:telegram_init_data) { 'user=%7B%22id%22%3A1029000609%2C%22first_name%22%3A%22Spooky%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22theacontigo%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=6719130073186955468&chat_type=private&auth_date=1692617684&hash=9c467fcab396b22e3670698cbb3cc9e7e486ce224c72c993ae295507a29f67bd' }

  describe '.call' do
    context 'when init data is VALID' do
      let!(:telegram_bot) { create(:cm_telegram_bot, token: valid_bot_token) }

      context 'when user is not yet connect with telegram provider' do
        it 'create a new user' do
          context = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)

          expect(context.success?).to eq true

          # created user
          expect(context.user.id).to be_present
          expect(context.user.first_name).to eq 'Spooky'
          expect(context.user.last_name).to eq ''
          expect(context.user.user_identity_providers.pluck(:sub)).to eq ['1029000609']
          expect(context.user.user_identity_providers.pluck(:name)).to eq ['theacontigo']
          expect(context.user.user_identity_providers.first.telegram_bots.pluck(:id)).to match_array [telegram_bot.id]

          # reference data
          expect(context.telegram_user['first_name']).to eq 'Spooky'
          expect(context.telegram_user['last_name']).to eq ''
          expect(context.telegram_user['id']).to eq 1029000609
          expect(context.telegram_user['username']).to eq 'theacontigo'
        end
      end

      context 'when user already connected to telegram provider' do
        it 'create return old user when user already already connected before' do
          context1 = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)
          context2 = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)

          expect(context1.success?).to eq true
          expect(context2.success?).to eq true
          expect(context1.user).to eq context2.user
        end
      end

      context 'when user already connected to telegram provider but provider & telegram_bot is not yet connected' do
        it 'create user_identity_provider_telegram_bots' do
          # create existing
          context1 = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)
          expect(context1.user.user_identity_providers.first.telegram_bots.pluck(:id)).to match_array [telegram_bot.id]

          # remove connection
          SpreeCmCommissioner::UserIdentityProviderTelegramBot.delete_all
          expect(context1.user.user_identity_providers.first.telegram_bots.pluck(:id)).to match_array []

          # when call service again, it should reconnect provider & telegram_bot
          context2 = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)

          expect(context2.success?).to eq true
          expect(context1.user).to eq context2.user
          expect(context2.user.user_identity_providers.first.telegram_bots.pluck(:id)).to match_array [telegram_bot.id]
        end
      end
    end

    context 'when init data is INVALID' do
      let!(:telegram_bot) { create(:cm_telegram_bot, token: invalid_bot_token) }

      it 'raise error' do
        context = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: telegram_bot.username)

        expect(context.success?).to eq false
        expect(context.message).to eq 'invalid_init_data'
      end
    end

    context 'when telegram_bot_username is invalid or not exist in db' do
      let!(:telegram_bot) { create(:cm_telegram_bot) }

      it 'return error' do
        context = described_class.call(telegram_init_data: telegram_init_data, telegram_bot_username: 'this-bot-not-exist')

        expect(context.success?).to eq false
        expect(context.message).to eq 'telegram_bot_username_is_not_valid_or_not_exist_in_db'
      end

      it 'return error when not pass the telegram_bot_username' do
        context = described_class.call(telegram_init_data: telegram_init_data)

        expect(context.success?).to eq false
        expect(context.message).to eq 'telegram_bot_username_is_not_valid_or_not_exist_in_db'
      end
    end
  end
end
