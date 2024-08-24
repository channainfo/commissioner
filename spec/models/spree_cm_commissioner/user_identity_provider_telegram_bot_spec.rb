require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserIdentityProviderTelegramBot, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user_identity_provider).required }
    it { is_expected.to belong_to(:telegram_bot).required }
  end

  describe '.last_sign_in' do
    let(:telegram_bot) { create(:cm_telegram_bot) }
    let(:user_identity_provider1) { create(:user_identity_provider, :telegram) }
    let(:user_identity_provider2) { create(:user_identity_provider, :telegram) }
    let(:user_identity_provider3) { create(:user_identity_provider, :telegram) }

    let!(:provider_telegram1) { described_class.create(telegram_bot: telegram_bot, user_identity_provider: user_identity_provider1, last_sign_in_at: Time.zone.now - 1.days)}
    let!(:provider_telegram2) { described_class.create(telegram_bot: telegram_bot, user_identity_provider: user_identity_provider2, last_sign_in_at: Time.zone.now)}
    let!(:provider_telegram3) { described_class.create(telegram_bot: telegram_bot, user_identity_provider: user_identity_provider3, last_sign_in_at: Time.zone.now - 2.days)}

    it 'return last sign in' do
      expect(described_class.last_sign_in).to eq provider_telegram2
    end
  end
end
