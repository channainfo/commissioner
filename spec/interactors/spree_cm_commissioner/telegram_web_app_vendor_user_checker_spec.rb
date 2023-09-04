require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramWebAppVendorUserChecker do
  let(:vendor) { build(:vendor) }
  let(:provider) { build(:user_identity_provider, :telegram, sub: '1029000609') }

  describe '.call' do
    let(:telegram_init_data) { 'user=%7B%22id%22%3A1029000609%2C%22first_name%22%3A%22Spooky%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22theacontigo%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%7D&chat_instance=6719130073186955468&chat_type=private&auth_date=1692617684&hash=9c467fcab396b22e3670698cbb3cc9e7e486ce224c72c993ae295507a29f67bd' }
    let(:decoded_telegram_init_data) { Rack::Utils.parse_nested_query(telegram_init_data).to_h }

    it 'failed when could not found user that connect with decoded_telegram_user_id' do
      context = described_class.call(decoded_telegram_init_data: decoded_telegram_init_data)

      expect(context.success?).to be false
      expect(context.message).to eq "Could not find connected user"
    end

    it 'failed when found connected user but user is not vendor user' do
      user = create(:user, user_identity_providers: [provider])
      context = described_class.call(decoded_telegram_init_data: decoded_telegram_init_data)

      expect(context.success?).to be false
      expect(context.user).to eq user
      expect(context.message).to eq "You're not a vendor user"
    end

    it 'success when found connected user & is a vendor user' do
      user = create(:user, user_identity_providers: [provider], vendors: [vendor])
      context = described_class.call(decoded_telegram_init_data: decoded_telegram_init_data)

      expect(context.success?).to be true
      expect(context.user.vendors.size).to eq 1
      expect(context.decoded_telegram_user_id).to eq 1029000609
    end
  end
end
