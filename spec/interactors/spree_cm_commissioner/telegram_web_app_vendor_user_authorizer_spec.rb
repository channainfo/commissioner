require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramWebAppVendorUserAuthorizer do
  let(:bot_token) { '6453379064:AAF8ISKbrDljptn6r5lMRj2Ben_s_ASmnnE' }
  let(:wrong_bot_token) { 'invalid-bot-token' }
  let(:telegram_init_data) { 'user=%7B%22id%22%3A1029000609%2C%22first_name%22%3A%22Spooky%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22theacontigo%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=6719130073186955468&chat_type=private&auth_date=1692617684&hash=9c467fcab396b22e3670698cbb3cc9e7e486ce224c72c993ae295507a29f67bd' }

  let(:vendor) { build(:vendor) }
  let(:provider) { build(:user_identity_provider, :telegram, sub: '1029000609') }

  describe '.call' do
    it 'failed when could not validated telegram init data' do
      context = described_class.call(telegram_init_data: telegram_init_data, bot_token: wrong_bot_token)

      expect(context.success?).to be false
      expect(context.message).to eq "Could not verify hash"
    end

    it 'failed when could not find connected user' do
      context = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)

      expect(context.success?).to be false
      expect(context.message).to eq "Could not find connected user"
    end

    it 'failed when connected user is not vendor user' do
      user = create(:user, user_identity_providers: [provider])
      context = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)

      expect(context.success?).to be false
      expect(context.message).to eq "You're not a vendor user"
    end

    it 'success when validated telegram data & found connected vendor user' do
      user = create(:user, user_identity_providers: [provider], vendors: [vendor])
      context = described_class.call(telegram_init_data: telegram_init_data, bot_token: bot_token)

      expect(context.success?).to be true
      expect(context.user.vendors.size).to eq 1
      expect(context.decoded_telegram_user_id).to eq 1029000609
    end
  end
end
