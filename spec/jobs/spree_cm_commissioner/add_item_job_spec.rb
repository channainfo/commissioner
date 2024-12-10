require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Cart::AddItemJob, type: :job do
  describe '#perform' do
    let(:order_id) { 1 }
    let(:variant_id) { 2 }
    let(:quantity) { 2 }
    let(:public_metadata) { { data: 'data' } }
    let(:private_metadata) { { data: 'info' } }
    let(:options) { { key: 'value' } }

    it 'calls SpreeCmCommissioner::Cart::AddItemHandler with correct arguments' do
      add_item_handler = class_double("SpreeCmCommissioner::Cart::AddItemHandler")
      allow(add_item_handler).to receive(:call).and_return(true)

      stub_const("SpreeCmCommissioner::Cart::AddItemHandler", add_item_handler)

      job = described_class.new
      allow(job).to receive(:job_id).and_return('test-job-id')

      job.perform(order_id, variant_id, quantity, public_metadata, private_metadata, options)

      expect(add_item_handler).to have_received(:call).with(
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
