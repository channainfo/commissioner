require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserPinCodeAuthenticator do
  let!(:pin_code) {
    create(:pin_code, :with_email, contact: 'panhachom@gmail.com',
                                                   type:'SpreeCmCommissioner::PinCodeRegistration')
    }
  describe '.call' do
    it 'create user with valid attributes' do
      options = {
        pin_code: pin_code.code,
        pin_code_token: pin_code.token,
        email: 'panhachom@gmail.com',
        password: '12345678',
        password_confirmation: '12345678',
        gender: 'male',
        dob: '2002-10-17'
      }
      registerer = described_class.call(options)

      expect(registerer.success?).to eq true
      expect(registerer.user.persisted?).to eq true
      expect(registerer.user.email).to eq 'panhachom@gmail.com'
      expect(registerer.user.dob.strftime('%Y-%m-%d')).to eq '2002-10-17'
      expect(pin_code.reload.expired?).to eq true

    end


    it 'return  false with message if attribute is invalid' do

      options = {
        pin_code: pin_code.code,
        pin_code_token: pin_code.token,
        email: 'panhachom@gmail.com',
        password: '123456',
        password_confirmation: '1234'
      }

      registerer = described_class.call(options)


      expect(registerer.success?).to eq false
      expect(registerer.message.present?).to eq true
    end
  end

  describe '#sanitize_contact' do
    it 'removes email if phone number exist' do
      options = { email: 'panhachom@gmail.com', phone_number: '0121234566' }
      registerer = described_class.new(options)
      registerer.send(:sanitize_contact)

      expect(registerer.context.email).to eq nil
    end

    it 'keep email is phone number is blank' do
      options = { email: 'panhachom@gmail.com', phone_number: '' }
      registerer = described_class.new(options)
      registerer.send(:sanitize_contact)

      expect(registerer.context.email).to eq 'panhachom@gmail.com'
    end
  end

  describe '#validate_pin_code!' do
    it 'return failed if pincode not found' do

      options = {
        pin_code: nil,
        pin_code_token: nil,
        email: 'panhachom@gmail.com'
      }

      registerer = described_class.new(options)
      expect { registerer.send(:validate_pin_code!) }.to raise_error Interactor::Failure
      expect(registerer.context.success?).to eq false
      expect(registerer.context.message).to eq 'Verification Code not found!'
    end

    it 'return success if pincode is correct' do
      options = {
        pin_code: pin_code.code,
        pin_code_token: pin_code.token,
        email: 'panhachom@gmail.com'
      }

      registerer = described_class.new(options)
      registerer.send(:validate_pin_code!)
      expect(registerer.context.success?).to eq true
    end
  end

  describe '#register_user!' do
    describe 'with valid attributes' do
      it 'save user and stripe out email if phone number exist' do
        options = {
          first_name: 'Panha',
          last_name: 'Chom',
          email: 'panhachom@gmail.com',
          phone_number: '012123456',
          password: '123456',
          password_confirmation: '123456'
        }

        registerer = described_class.new(options)
        registerer.send(:register_user!)

        expect(registerer.context.user.persisted?).to eq true
        expect(registerer.context.user.first_name).to eq 'Panha'
        expect(registerer.context.user.last_name).to eq 'Chom'

        expect(registerer.context.user.phone_number).to eq '012123456'
        expect(registerer.context.user.email).to eq nil
      end

      it 'saves user with email if phone number does not exist' do

        options = {
          first_name: 'Panha',
          last_name: 'Chom',
          email: 'panhachom@gmail.com',
          password: '123456',
          password_confirmation: '123456'
        }

        registerer = described_class.new(options)
        registerer.send(:register_user!)

        expect(registerer.context.user).to_not eq nil
        expect(registerer.context.user.persisted?).to eq true
        expect(registerer.context.user.first_name).to eq 'Panha'
        expect(registerer.context.user.last_name).to eq 'Chom'

        expect(registerer.context.user.phone_number).to eq nil
        expect(registerer.context.user.email).to eq 'panhachom@gmail.com'
      end
    end

    describe 'invalid attributes' do
      it 'fails with mesage' do

        options = {
          first_name: 'Panha',
          last_name: 'Chome',
          email: '',
          password: '123456',
          password_confirmation: ''
        }

        registerer = described_class.new(options)

        expect { registerer.send(:register_user!) }.to raise_error Interactor::Failure
        expect(registerer.context.success?).to eq false
        expect(registerer.context.message.present?).to eq true
      end
    end
  end
end
