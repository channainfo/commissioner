require 'spec_helper'

RSpec.describe CmAppLogger do
  describe '.log' do
    let(:label) { 'test_event' }
    let(:data) { { key: 'value' } }
    let(:message) { { label: label, data: data } }
    let(:current_time) { Time.current }

    before do
      # Mock Rails.logger
      allow(Rails.logger).to receive(:info)
      # Freeze time for consistent duration calculations
      allow(Time).to receive(:current).and_return(current_time)
    end

    context 'without a block' do
      it 'logs a message with label and data' do
        expect(Rails.logger).to receive(:info).with(message.to_json)
        CmAppLogger.log(label: label, data: data)
      end

      it 'logs a message with label only when data is nil' do
        message = { label: label, data: nil }
        expect(Rails.logger).to receive(:info).with(message.to_json)
        CmAppLogger.log(label: label)
      end

      it 'does not yield or log a second message' do
        expect(Rails.logger).to receive(:info).once.with({ label: label, data: nil }.to_json)
        CmAppLogger.log(label: label)
      end
    end

    context 'with a block' do
      it 'logs the initial message, yields, and logs the message with duration' do
        # Simulate time passing (100ms)
        allow(Time).to receive(:current).and_return(current_time, current_time + 0.1)
        message_with_duration = message.merge(start_time: current_time, duration_ms: 100.0)

        expect(Rails.logger).to receive(:info).with(message.to_json).ordered
        expect(Rails.logger).to receive(:info).with(message_with_duration.to_json).ordered
        expect { |b| CmAppLogger.log(label: label, data: data, &b) }.to yield_control

        CmAppLogger.log(label: label, data: data) { :do_something }
      end

      it 'yields to the provided block' do
        block_called = false
        CmAppLogger.log(label: label) { block_called = true }
        expect(block_called).to be true
      end

      it 'calculates duration_ms correctly' do
        # Simulate 50ms passing
        allow(Time).to receive(:current).and_return(current_time, current_time + 0.05)
        message_with_duration = { label: label, data: nil, start_time: current_time, duration_ms: 50.0 }

        expect(Rails.logger).to receive(:info).with({ label: label, data: nil }.to_json).ordered
        expect(Rails.logger).to receive(:info).with(message_with_duration.to_json).ordered

        CmAppLogger.log(label: label) { :do_something }
      end
    end
  end
end
