require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ApplicationJobDecorator do
  class TestJob < ::ApplicationJob
    def perform
    end
  end

  describe 'discard_on ActiveJob::DeserializationError' do
    let(:order) { create(:completed_order_with_pending_payment) }

    before do
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.performed_jobs.clear
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
      order.destroy
    end

    it 'verifies that the exception does not propagate' do
      expect {
        Noticed::DeliveryMethods::Fcm.perform_later(order)
      }.not_to raise_error
    end

    it 'calls handle_deserialization_error' do
      allow(SpreeCmCommissioner::ApplicationJobDecorator).to receive(:handle_deserialization_error)
      job = Noticed::DeliveryMethods::Fcm.perform_later(order)

      expect(SpreeCmCommissioner::ApplicationJobDecorator).to have_received(:handle_deserialization_error).with(an_instance_of(Noticed::DeliveryMethods::Fcm), an_instance_of(ActiveJob::DeserializationError))
    end
  end

  describe '.handle_deserialization_error' do
    let(:job) { instance_double('TestJob', class: 'TestJob', as_json: { 'id' => 123, 'arguments' => [] }) }
    let(:error) { StandardError.new(message: 'Error while trying to deserialize arguments', backtrace: []) }

    before do
      allow(CmAppLogger).to receive(:log)
      described_class.handle_deserialization_error(job, error)
    end

    it 'logs the error with the job details' do
      expect(CmAppLogger).to have_received(:log).with(
        label: "TestJob: {:message=>\"Error while trying to deserialize arguments\", :backtrace=>[]}",
        data: {'id'=>123, 'arguments'=>[]}
      )
    end
  end
end
