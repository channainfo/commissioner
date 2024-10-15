require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ChatraceOrderCreator, :vcr do
  let(:product) { create(:cm_event_product) }
  let(:variant) { product.master }
  let(:queue_guest_token) { SecureRandom.uuid }

  describe '.call' do
    let(:chatrace_user_id) { '734348432' }
    let(:chatrace_return_flow_id) { '1728985704288' }
    let(:chatrace_api_host) { 'app.chatgd.com' }
    let(:chatrace_access_token) { '1663219.TIr7mU295Hm0FIyD2hyxMSOed059Jrl4' }
    let(:order_params) do
      {
        variant_id: variant.id,
        order_email: 'sample@gmail.com',
        order_phone_number: '+85512345678',
        first_name: 'Thea',
        last_name: 'Choem',
        age: 20
      }
    end

    context 'when params & order params are valid' do
      it 'create order & notify user' do
        context = described_class.call(
          chatrace_user_id: chatrace_user_id,
          chatrace_return_flow_id: chatrace_return_flow_id,
          chatrace_api_host: chatrace_api_host,
          chatrace_access_token: chatrace_access_token,
          order_params: order_params,
          guest_token: queue_guest_token,
        )

        expect(context.order_creator.order.state).to eq 'complete'
        expect(context.order_creator.order.payment_state).to eq 'paid'
        expect(context.order_creator.order.guests.first.token).to eq queue_guest_token
      end
    end

    context 'when order params is invalid' do
      let(:order_params) { { order_email: 'sample@gmail.com', age: 20 } }

      it 'does not create order or notify user' do
        context = described_class.call(
          chatrace_user_id: chatrace_user_id,
          chatrace_return_flow_id: chatrace_return_flow_id,
          chatrace_api_host: chatrace_api_host,
          chatrace_access_token: chatrace_access_token,
          order_params: order_params,
          guest_token: queue_guest_token,
        )

        expect(context.success?).to be false
        expect(context.order_creator.success?).to be false
        expect(context.message).to eq 'variant_id_is_required'
      end
    end
  end
end