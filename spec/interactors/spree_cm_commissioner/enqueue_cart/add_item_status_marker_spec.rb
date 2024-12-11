require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnqueueCart::AddItemStatusMarker do
  let(:order_number) { 'R12345678' }
  let(:job_id) { 'job_456' }
  let(:status) { 'processing' }
  let(:queued_at) { Time.now }

  subject { described_class.new(order_number: order_number, job_id: job_id, status: status, queued_at: queued_at) }

  describe '#call' do
    it 'fails when order_number is missing' do
      allow(subject).to receive(:order_number).and_return(nil)
      expect { subject.call }.to raise_error(Interactor::Failure)
    end

    it 'fails when job_id is missing' do
      allow(subject).to receive(:job_id).and_return(nil)
      expect { subject.call }.to raise_error(Interactor::Failure)
    end

    it 'fails when status is missing' do
      allow(subject).to receive(:status).and_return(nil)
      expect { subject.call }.to raise_error(Interactor::Failure)
    end
  end
end
