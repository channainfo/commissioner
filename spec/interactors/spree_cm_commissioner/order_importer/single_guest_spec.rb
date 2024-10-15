require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrderImporter::SingleGuest do
  describe '#call' do
    let(:product) { create(:cm_event_product) }
    let(:variant) { product.master }

    context 'when params is valid' do
      let(:params) do
        {
          variant_id: variant.id,
          order_email: 'sample@gmail.com',
          order_phone_number: '+85512345678',
          first_name: 'Thea',
          last_name: 'Choem',
          age: 20,
        }
      end

      it 'created 1 order with 1 line item & 1 guest' do
        context = described_class.call(params: params)

        expect(context.success?).to be true

        expect(context.order.state).to eq 'complete'
        expect(context.order.payment_state).to eq 'paid'
        expect(context.order.email).to eq params[:order_email]
        expect(context.order.intel_phone_number).to eq params[:order_phone_number]

        expect(context.order.line_items.size).to eq 1
        expect(context.order.guests.size).to eq 1

        expect(context.order.guests.first.first_name).to eq params[:first_name]
        expect(context.order.guests.first.last_name).to eq params[:last_name]
      end
    end

    context 'when no variant_id provide in params' do
      let(:params) do
        {
          order_email: 'sample@gmail.com',
          order_phone_number: '+85512345678',
          first_name: 'Thea',
          last_name: 'Choem',
          age: 20,
        }
      end

      it 'raise error' do
        context = described_class.call(params: params)

        expect(context.success?).to be false
        expect(context.message).to eq 'variant_id_is_required'
      end
    end

    context 'when no contact provide in params' do
      let(:params) do
        {
          variant_id: variant.id,
          first_name: 'Thea',
          last_name: 'Choem',
          age: 20,
        }
      end

      it 'raise error' do
        context = described_class.call(params: params)

        expect(context.success?).to be false
        expect(context.message).to eq 'email_or_phone_is_required'
      end
    end
  end
end
