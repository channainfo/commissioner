require 'spec_helper'

RSpec.describe Spree::User, type: :model do
  describe 'associations' do
    it { should have_many(:user_events).class_name('SpreeCmCommissioner::UserEvent') }
    it { should have_many(:events).through(:user_events).source(:taxon).class_name('Spree::Taxon') }
  end

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

  describe '#full_name' do
    it 'return full name empty string when both first name and last name is empty or nil' do
      user1 = create(:user, first_name: '', last_name: '')
      user2 = create(:user, first_name: ' ', last_name: ' ')
      user3 = create(:user, first_name: nil, last_name: nil)

      expect(user1.full_name).to eq ''
      expect(user2.full_name).to eq ''
      expect(user3.full_name).to eq ''
    end

    it 'return only return first name when last name is empty or nil' do
      user1 = create(:user, first_name: 'First', last_name: '')
      user2 = create(:user, first_name: 'First', last_name: ' ')
      user3 = create(:user, first_name: 'First', last_name: nil)

      expect(user1.full_name).to eq 'First'
      expect(user2.full_name).to eq 'First'
      expect(user3.full_name).to eq 'First'
    end

    it 'return only return last name when first name is empty or nil' do
      user1 = create(:user, first_name: '', last_name: 'Last')
      user2 = create(:user, first_name: ' ', last_name: 'Last')
      user3 = create(:user, first_name: nil, last_name: 'Last')

      expect(user1.full_name).to eq 'Last'
      expect(user2.full_name).to eq 'Last'
      expect(user3.full_name).to eq 'Last'
    end

    it 'return full name when both first name and last name exist' do
      user = create(:user, first_name: 'First', last_name: 'Last')

      expect(user.full_name).to eq 'First Last'
    end
  end

  describe '#update_otp_enabled' do
    let(:user) { build(:cm_user) }

    context 'when otp_email or otp_phone_number is true' do
      it 'sets otp_enabled to true' do
        user.otp_email = true
        user.save
        expect(user.otp_enabled).to be true
      end
    end

    context 'when otp_email and otp_phone_number are false' do
      it 'sets otp_enabled to false' do
        user.otp_email = false
        user.otp_phone_number = false
        user.save
        expect(user.otp_enabled).to be false
      end
    end
  end

  describe 'validations the same login or email with different tenant' do
    let!(:tenant1) { create(:cm_tenant, id: 1) }
    let!(:tenant2) { create(:cm_tenant, id: 2) }

    context 'with the same phone number and login in different tenants' do
      let!(:user1) { create(:cm_user, phone_number: '0123456789', login: 'user1', tenant_id: tenant1.id) }

      it 'allows phone number with the same value for different tenants' do
        user2 = build(:cm_user, phone_number: '0123456789', tenant_id: tenant2.id)
        expect(user2).to be_valid
      end

      it 'allows login with the same value for different tenants' do
        user2 = build(:cm_user, login: 'user1', tenant_id: tenant2.id)
        expect(user2).to be_valid
      end
    end

    context 'with the same phone number and login in the same tenant' do
      let!(:user1) { create(:cm_user, phone_number: '0123456789', login: 'user1', tenant_id: tenant1.id) }

      it 'does not allow phone number duplication within the same tenant' do
        user2 = build(:cm_user, phone_number: '0123456789', tenant_id: tenant1.id)
        expect(user2).to be_invalid
        expect(user2.errors[:phone_number]).to include('has already been taken')
      end

      it 'does not allow login duplication within the same tenant' do
        user2 = build(:cm_user, login: 'user1', tenant_id: tenant1.id)
        expect(user2).to be_invalid
        expect(user2.errors[:login]).to include('has already been taken')
      end
    end
  end
end
