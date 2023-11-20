require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Sms do
  describe '#sms_options' do
    it 'return sms options' do
      sms = SpreeCmCommissioner::Sms.new(to: '0888848286', body: 'valid')
      allow(sms).to receive(:sanitize).and_return('+855888848286')
      allow(sms).to receive(:from_number).and_return('CentralMarket')
      result = sms.send(:sms_options)
      expect(result).to match to: '+855888848286', body: 'valid', from: 'CentralMarket'
    end
  end

  describe '#from_number' do
    it 'return sender number if the `from` option exist' do
      sms = SpreeCmCommissioner::Sms.new(from: 'CentralMarket', to: '+855888848286', body: 'valid')
      from_number = sms.send(:from_number)
      expect(from_number).to eq 'CentralMarket'
    end

    it 'return sender number from SMS_SENDER_ID env if it is present' do
      ENV['SMS_SENDER_ID'] = 'CENTRAL MARKET LIVE'
      sms = SpreeCmCommissioner::Sms.new(to: '+855888848286', body: 'valid')
      from_number = sms.send(:from_number)

      expect(from_number).to eq ENV['SMS_SENDER_ID']
    end

    it 'return SMS Info if SMS_SENDER_ID env is mising' do
      ENV['SMS_SENDER_ID'] = ''
      sms = SpreeCmCommissioner::Sms.new(to: '+855888848286', body: 'valid')
      from_number = sms.send(:from_number)

      expect(from_number).to eq 'SMS Info'
    end
  end

  describe '#sanitize' do
    it 'sanitize recipient number' do
      opts = { to: '+855888848286', body: 'valid' }
      sms = SpreeCmCommissioner::Sms.new(opts)
      number = sms.send(:sanitize, '+855888848286')
      expect(number).to eq '+855888848286'
    end

    it 'sanitize recipient number' do
      opts = { to: '+855888848286', body: '' }
      sms = SpreeCmCommissioner::Sms.new(opts)
      number = sms.send(:sanitize, '0888848286')
      expect(number).to eq '+855888848286'
    end
  end

  describe '.call' do
    describe 'input invalid' do
      it 'requires to field to be present' do
        count = SpreeCmCommissioner::SmsLog.count
        options = { to: '', body: 'Message Body...' }
        context = SpreeCmCommissioner::Sms.call(options)

        expect(context.success?).to eq false
        expect(context.message).to eq 'recipient can not be blank'
        expect(SpreeCmCommissioner::SmsLog.count).to eq (count)
      end

      it 'requires to field to be present' do
        options = { to: '+855888848286', body: '' }
        context = SpreeCmCommissioner::Sms.call(options)
        expect(context.success?).to eq false
        expect(context.message).to eq 'sms content can not be blank'
      end
    end

    describe 'input valid' do
      it 'send message and create sms log without api connection error' do
        count = SpreeCmCommissioner::SmsLog.count
        options = { to: '+85587420441', body: 'Message Body...' }
        sms_options = options.merge(from: 'centralMarket')

        allow_any_instance_of(SpreeCmCommissioner::Sms).to receive(:create_message).with(sms_options)
        context = SpreeCmCommissioner::Sms.call(sms_options)

        expect(context.success?).to eq true
        expect(SpreeCmCommissioner::SmsLog.count).to eq ( count + 1 )

        sms_log = context.sms_log
        expect(sms_log.from_number).to eq 'centralMarket'
        expect(sms_log.to_number).to eq '+85587420441'
        expect(sms_log.body).to eq 'Message Body...'
        expect(sms_log.adapter_name).to_not eq nil
        expect(sms_log.error).to eq nil
      end

      it 'failed with error message with api connection error' do
        count = SpreeCmCommissioner::SmsLog.count
        allow_any_instance_of(SpreeCmCommissioner::Sms).to receive(:create_message).and_raise(SpreeCmCommissioner::ConnectionError.new('connection error'))

        options = { to: '+855888848286', body: 'Message Body...', from: 'centralMarket' }
        context = SpreeCmCommissioner::Sms.call(options)

        expect(context.success?).to eq false
        expect(context.message).to eq 'connection error'
        expect(SpreeCmCommissioner::SmsLog.count).to eq (count+1)

        sms_log = context.sms_log
        expect(sms_log.from_number).to eq 'centralMarket'
        expect(sms_log.to_number).to eq '+855888848286'
        expect(sms_log.body).to eq 'Message Body...'
        expect(sms_log.error).to eq 'connection error'
      end
    end
  end

  context 'plasgate adapter' do
    it 'update sms log queue_id after create message' do
      success_response = double(:response, status: 200, body: "{\n  \"message_count\": 1, \n  \"queue_id\": \"2448cbec-822b-4a46-b216-e1cb6a3c5a86\"\n}\n")

      allow_any_instance_of(SpreeCmCommissioner::Sms).to receive(:adapter).and_return(SmsAdapter::Plasgate.new)
      allow_any_instance_of(SmsAdapter::Plasgate).to receive(:request).and_return(success_response)

      sms_options = { from: 'SMS Info', to: '+85512345678', body: 'Message Body...' }
      context = SpreeCmCommissioner::Sms.call(sms_options)

      expect(context.sms_log.external_ref).to eq "2448cbec-822b-4a46-b216-e1cb6a3c5a86"
      expect(context.sms_log.adapter_name).to eq "Plasgate"
    end
  end
end

