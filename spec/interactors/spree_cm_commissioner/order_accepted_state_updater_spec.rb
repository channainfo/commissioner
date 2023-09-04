require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderAcceptedStateUpdater do
  let(:order) { create(:order_with_line_items , request_state: :requested , state: :complete) }
  let!(:product) { create(:cm_accommodation_product, permanent_stock: 3) }
  let!(:line_item) { create(:line_item, quantity: 3, order: order, product: product ) }

  let(:user) { create(:cm_user) }

  describe '.call' do
      it 'success update request state' do
        context = described_class.call(order: order, authorized_user: user)

        expect(order.request_state).to eq('accepted')
        expect(order.line_items.first.accepted_at).to_not eq nil
        expect(order.line_items.first.accepted_by).to eq user
      end

      it 'fail if request state is not requested' do
        order = create(:order_with_line_items , request_state: nil , state: :complete)
        context = described_class.call(order: order, authorized_user: user)

        expect(context.message).to eq('error while update state')
      end
  end
end