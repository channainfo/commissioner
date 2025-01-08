require 'spec_helper'

RSpec.describe CmAppLogger do
  describe '.log' do
    let(:label) { 'Log Label' }
    let(:data) { { key: 'value' } }
    let(:expected_message) { { label: label, data: data }.to_json }

    it 'logs the message with the correct format' do
      expect(Rails.logger).to receive(:info).with(expected_message)
      CmAppLogger.log(label: label, data: data)
    end

    it 'logs the message without data' do
      expected_message_without_data = { label: label, data: nil }.to_json
      expect(Rails.logger).to receive(:info).with(expected_message_without_data)
      CmAppLogger.log(label: label)
    end
  end
end
