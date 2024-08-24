require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramBot, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:token) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:user_identity_provider_telegram_bots) }
    it { is_expected.to have_many(:user_identity_providers).through(:user_identity_provider_telegram_bots) }
  end
end
