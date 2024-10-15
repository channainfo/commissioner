require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ChatraceOrderCreatorJob, type: :job do
  let(:product) { create(:cm_event_product) }
  let(:variant) { product.master }

  let(:options) do
    {
      chatrace_user_id: '734348432',
      chatrace_return_flow_id: '1728985704288',
      chatrace_api_host: 'app.chatgd.com',
      chatrace_access_token: '1663219.TIr7mU295Hm0FIyD2hyxMSOed059Jrl4',
      order_params: {
        variant_id: variant.id,
        order_email: 'sample@gmail.com',
        order_phone_number: '+85512345678',
        first_name: 'Thea',
        last_name: 'Choem',
        age: 20
      }
    }
  end

  describe '#perform' do
    it 'calls ChatraceOrderCreator with the correct options' do
      expect(SpreeCmCommissioner::ChatraceOrderCreator).to receive(:call).with(options)

      described_class.perform_now(options)
    end
  end

  describe 'job queueing' do
    it 'enqueues the job' do
      expect {
        described_class.perform_later(options)
      }.to have_enqueued_job(described_class)
        .with(options)
        .on_queue('default') # Assuming the default queue
    end
  end
end
