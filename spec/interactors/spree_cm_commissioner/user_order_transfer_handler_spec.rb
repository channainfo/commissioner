require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserOrderTransferHandler, type: :interactor do
  let(:user) { create(:cm_user, email: 'user@example.com', phone_number: '123-456-7890') }
  let(:order1) { create(:order, user_id: nil, email: 'user@example.com' , state: 'complete') }
  let(:order2) { create(:order, user_id: nil, phone_number: '123-456-7890',  state: 'complete') }
  let(:order3) { create(:order, user_id: user.id) }
  let(:order4) { create(:order, user_id: nil, email: 'another@example.com', phone_number: '098-765-4321', state: 'complete') }

  describe '.call' do

    context 'when the orders exist' do
      it 'transfers the orders to the user if user_id is nil and email matches' do
        interactor = described_class.call(user: user, order_numbers: [order1.number])

        expect(interactor.success?).to be true
        expect(order1.reload.user_id).to eq(user.id)
        expect(interactor.successful_orders).to include(order1)
      end

      it 'transfers the orders to the user if user_id is nil and phone matches' do
        interactor = described_class.call(user: user, order_numbers: [order2.number])

        expect(interactor.success?).to be true
        expect(order2.reload.user_id).to eq(user.id)
        expect(interactor.successful_orders).to include(order2)
      end
    end

    context 'when no orders are found' do
      it 'fails with an error message' do
        interactor = described_class.call(user: user, order_numbers: ['R0000001', 'R0000002'])

        expect(interactor).to be_failure
        expect(interactor.message).to eq('No orders found.')
      end
    end
  end
end
