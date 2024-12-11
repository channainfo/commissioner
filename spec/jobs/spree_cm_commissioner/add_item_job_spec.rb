require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnqueueCart::AddItemJob, type: :job do
  describe '#perform' do
    let(:order_id) { 1 }
    let(:variant_id) { 2 }
    let(:quantity) { 2 }
    let(:public_metadata) { { data: 'data' } }
    let(:private_metadata) { { data: 'info' } }
    let(:options) { { key: 'value' } }

    it 'calls SpreeCmCommissioner::EnqueueCart::AddItem with correct arguments' do
      add_item = class_double("SpreeCmCommissioner::EnqueueCart::AddItem")
      allow(add_item).to receive(:call).and_return(true)

      stub_const("SpreeCmCommissioner::EnqueueCart::AddItem", add_item)

      job = described_class.new
      allow(job).to receive(:job_id).and_return('test-job-id')

      job.perform(order_id, variant_id, quantity, public_metadata, private_metadata, options)

      expect(add_item).to have_received(:call).with(
        order_id: order_id,
        variant_id: variant_id,
        quantity: quantity,
        public_metadata: public_metadata,
        private_metadata: private_metadata,
        options: options,
        job_id: 'test-job-id'
      )
    end
  end
end
