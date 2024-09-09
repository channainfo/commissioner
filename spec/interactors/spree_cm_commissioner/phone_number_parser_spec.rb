require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PhoneNumberParser do
  context 'valid phone number' do
    before(:each) do
      Phonelib.default_country = "KH"
    end

    it 'extracted phone number formats on intl phone_number' do
      parser = described_class.call(phone_number: '+855964103875')

      expect(parser.intel_phone_number).to eq "+855964103875"
      expect(parser.national_phone_number).to eq "0964103875"
    end

    it 'extracted phone number formats on intl phone_number without +' do
      parser = described_class.call(phone_number: '855964103875')

      expect(parser.intel_phone_number).to eq "+855964103875"
      expect(parser.national_phone_number).to eq "0964103875"
    end

    it 'extracted phone number formats on phone_number with prefix 0' do
      parser = described_class.call(phone_number: '096 4103 875')

      expect(parser.intel_phone_number).to eq "+855964103875"
      expect(parser.national_phone_number).to eq "0964103875"
    end

    it 'extracted phone number formats on phone_number with prefix 0' do
      parser = described_class.call(phone_number: '96 4103 875')

      expect(parser.intel_phone_number).to eq "+855964103875"
      expect(parser.national_phone_number).to eq "0964103875"
    end
  end

  context 'invalid phone number' do
    before(:each) do
      Phonelib.default_country = "KH"
    end

    it 'return intl & national phone null on empty phone_number' do
      parser = described_class.call(phone_number: ' ')

      expect(parser.phone_number).to eq ' '
      expect(parser.intel_phone_number).to eq nil
      expect(parser.national_phone_number).to eq nil
    end

    it 'return intl & national phone null on incorrect length phone_number' do
      parser = described_class.call(phone_number: '12345')

      expect(parser.intel_phone_number).to eq nil
      expect(parser.national_phone_number).to eq nil
    end
  end

  context 'country_code' do
    it 'return int & national phone base on specified country_code' do
      Phonelib.default_country = "KH"
      parser = described_class.call(phone_number: '6622549836', country_code: 'TH')

      expect(parser.intel_phone_number).to eq "+6622549836"
      expect(parser.national_phone_number).to eq "022549836"
    end

    it 'return int & national phone base on default when no country_code provided' do
      Phonelib.default_country = "KH"
      parser = described_class.call(phone_number: '0964103875')

      expect(parser.intel_phone_number).to eq "+855964103875"
      expect(parser.national_phone_number).to eq "0964103875"
    end
  end
end
