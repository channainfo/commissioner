require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserCartItemCountUpdater, type: :model do
  let(:order) { create(:order) }
  let(:updater) { described_class.new }

  describe '#call' do
    context 'when context is successful and order is a current cart' do
      let(:context) { double('context', success?: true, current_cart?: true) }

      it 'enqueues UserCartItemCountJob' do
        expect(SpreeCmCommissioner::UpdateUserCartItemCountHandler).to receive(:call).with(order: order).and_return(context)
        expect(SpreeCmCommissioner::UserCartItemCountJob).to receive(:perform_later).with(order.id)

        updater.call(order: order)
      end
    end

    context 'when context is not successful' do
      let(:context) { double('context', success?: false, current_cart?: true) }

      it 'does not enqueue UserCartItemCountJob' do
        expect(SpreeCmCommissioner::UpdateUserCartItemCountHandler).to receive(:call).with(order: order).and_return(context)
        expect(SpreeCmCommissioner::UserCartItemCountJob).not_to receive(:perform_later)

        updater.call(order: order)
      end
    end

    context 'when order is not a current cart' do
      let(:context) { double('context', success?: true, current_cart?: false) }

      it 'does not enqueue UserCartItemCountJob' do
        expect(SpreeCmCommissioner::UpdateUserCartItemCountHandler).to receive(:call).with(order: order).and_return(context)
        expect(SpreeCmCommissioner::UserCartItemCountJob).not_to receive(:perform_later)

        updater.call(order: order)
      end
    end

    context 'when context is not successful and order is not a current cart' do
      let(:context) { double('context', success?: false, current_cart?: false) }

      it 'does not enqueue UserCartItemCountJob' do
        expect(SpreeCmCommissioner::UpdateUserCartItemCountHandler).to receive(:call).with(order: order).and_return(context)
        expect(SpreeCmCommissioner::UserCartItemCountJob).not_to receive(:perform_later)

        updater.call(order: order)
      end
    end

    context 'showing result' do
      let(:user) { create(:cm_user, cart_item_count: 0) }
      let(:order) { create(:order, item_count: 1, user: user) }

      it 'updates user cart_item_count' do
        updater.call(order: order)
        expect(user.cart_item_count).to eq(1)
      end

      it 'enques UserCartItemCountJob' do
        expect {
          updater.call(order: order)
        }.to have_enqueued_job(SpreeCmCommissioner::UserCartItemCountJob).with(order.id)
      end
    end
  end
end