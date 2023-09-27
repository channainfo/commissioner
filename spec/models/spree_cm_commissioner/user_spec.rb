require 'spec_helper'

RSpec.describe Spree::User, type: :model do
  describe '.require_login_identity_all_blank_for' do
    it 'not required email, phone, or login if already has user_identity_providers' do
      user = build(
        :cm_user,
        phone_number: nil,
        email: nil,
        login: nil,
        user_identity_providers: [build(:user_identity_provider)],
      )
      expect(user.send(:require_login_identity_all_blank_for, :email)).to be false
      expect(user.send(:require_login_identity_all_blank_for, :login)).to be false
      expect(user.send(:require_login_identity_all_blank_for, :phone_number)).to be false
    end
  end

  describe '.find_user_by_login' do
    let!(:user) { create(:cm_user, password: 'correct-password', phone_number: "0123456789", email: "test@gmail.com") }

    it 'return user by uppercase email' do
      expect(described_class.find_user_by_login(user.email.upcase)).to eq user
    end

    it 'return user by randomcase email' do
      expect(described_class.find_user_by_login('tESt@gmail.com')).to eq user
    end

    it 'return user by phone_number' do
      expect(described_class.find_user_by_login('0123456789')).to eq user
    end

    it 'return user by intel_phone_number with space' do
      expect(described_class.find_user_by_login('+855 123456789')).to eq user
    end

    it 'return user by intel_phone_number' do
      expect(described_class.find_user_by_login('+855123456789')).to eq user
    end

    it 'return user by login' do
      expect(described_class.find_user_by_login(user.login)).to eq user
    end

    it 'return nil when can not find login' do
      expect(described_class.find_user_by_login('invalid')).to eq nil
    end
  end
end
