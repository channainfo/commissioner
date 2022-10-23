require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserIdentityChecker do
  let(:user) { create(:user) }

  describe '.call' do
    it 'return user if identity matched' do
      create(:user_identity_provider, user: user, identity_type: 'google', sub: '104389993318125584446')
      identity_checker = described_class.call(identity_type: 'google', sub: '104389993318125584446')

      expect(identity_checker.success?).to eq true
      expect(identity_checker.user).to eq user
    end

    it 'return nil if user provider does not exist' do
      identity_checker = described_class.call(identity_type: 'google', sub: 'invalid')

      expect(identity_checker.success?).to eq false
      expect(identity_checker.message).to eq('User identity provider for google not found in the system')
    end
  end

  describe '#load_user' do
    it 'return user if user identity provider is found' do
      create(:user_identity_provider, user: user, identity_type: 'google', sub: '104389993318125584446')
      checker = described_class.new(identity_type: 'google', sub: '104389993318125584446')
      checker.load_user

      expect(checker.context.user).to eq user
    end
  end
end