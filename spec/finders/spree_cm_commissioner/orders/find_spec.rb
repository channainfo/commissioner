require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Orders::Find do
  let(:store) { create(:store) }
  let(:currency) { 'USD' }
  let(:user)  { create(:user) }

  subject(:finder) { described_class.new }

  describe '#execute' do
    context 'when token is present' do
      it 'returns the matching order' do
        order = create(:order, store: store, currency: currency, token: 'abc123')

        result = finder.execute(store: store, user: nil, currency: currency, token: 'abc123')

        expect(result).to eq(order)
      end

      it 'returns nil if order is canceled' do
        create(:order, store: store, currency: currency, token: 'abc123', state: 'canceled')

        result = finder.execute(store: store, user: nil, currency: currency, token: 'abc123')

        expect(result).to be_nil
      end

      it 'returns nil if order is archived' do
        create(:order, store: store, currency: currency, token: 'abc123', archived_at: Time.current)

        result = finder.execute(store: store, user: nil, currency: currency, token: 'abc123')

        expect(result).to be_nil
      end
    end

    context 'when token is not present but user is present' do
      it 'returns the most recent order for the user' do
        _old_order = create(:order, store: store, user: user, currency: currency, created_at: 2.days.ago)
        latest_order = create(:order, store: store, user: user, currency: currency, created_at: 1.hour.ago)

        result = finder.execute(store: store, user: user, currency: currency)

        expect(result).to eq(latest_order)
      end

      it 'returns nil if no matching order is found' do
        result = finder.execute(store: store, user: user, currency: currency)

        expect(result).to be_nil
      end

      it 'excludes canceled and archived orders' do
        create(:order, store: store, user: user, currency: currency, state: 'canceled')
        create(:order, store: store, user: user, currency: currency, archived_at: Time.current)

        result = finder.execute(store: store, user: user, currency: currency)

        expect(result).to be_nil
      end
    end

    context 'when neither token nor user is present' do
      it 'returns nil' do
        result = finder.execute(store: store, user: nil, currency: currency)

        expect(result).to be_nil
      end
    end

    context 'when state is present' do
      it 'returns an order matching the given state' do
        create(:order, store: store, user: user, currency: currency, state: 'cart')
        payment_order = create(:order, store: store, user: user, currency: currency, state: 'payment')

        result = finder.execute(store: store, user: user, currency: currency, state: 'payment')

        expect(result).to eq(payment_order)
      end

      it 'returns nil if no order matches the given state' do
        create(:order, store: store, user: user, currency: currency, state: 'cart')

        result = finder.execute(store: store, user: user, currency: currency, state: 'payment')

        expect(result).to be_nil
      end
    end
  end
end
