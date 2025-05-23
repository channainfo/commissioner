require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ApplicationUniqueJob, type: :job do
  include ActiveJob::TestHelper

  # Sample job class for testing
  class TestUniqueJob < described_class
    def perform(*args)
      raise "Test error" if args.first == :raise_error
      # Simulate successful job execution
      true
    end
  end

  let(:job_arguments) { [123, "update"] }
  let(:error) { StandardError.new("Test error") }

  before do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.performed_jobs.clear
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true

    # Stub CmAppLogger to avoid actual logging and capture the call
    allow(CmAppLogger).to receive(:log)
  end

  describe "#log_exceptions" do
    context "when an exception is raised" do
      it "logs the error details and re-raises the exception" do
        expect(CmAppLogger).to receive(:log)

        # Expect the exception to be re-raised
        expect {
          TestUniqueJob.perform_later(:raise_error, "update")
        }.to raise_error(StandardError, "Test error")

      end
    end

    context "when no exception is raised" do
      it "does not log anything and completes the job" do
        expect(CmAppLogger).not_to receive(:log)

        perform_enqueued_jobs do
          TestUniqueJob.perform_later(*job_arguments)
        end

        # Verify the job was executed without errors
        expect(TestUniqueJob).to have_been_performed.with(*job_arguments)
      end
    end
  end
end
