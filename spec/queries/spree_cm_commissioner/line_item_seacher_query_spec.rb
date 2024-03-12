require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemSearcherQuery do
  describe '#call' do
    let(:params) { {} }
    let(:query) { described_class.new(params) }

    context 'when qr_data is present' do
      let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXGCUzA1708344610539' } }
      let(:order) { instance_double('Spree::Order') }
      let(:line_items) { double('line_items') }

      before do
        allow(Spree::Order).to receive(:search_by_qr_data!).with(params[:qr_data]).and_return(order)
        allow(order).to receive(:line_items).and_return(line_items)
      end

      it 'calls search_by_qr_data! with qr_data' do
        query.call
        expect(Spree::Order).to have_received(:search_by_qr_data!).with(params[:qr_data])
      end

      it 'returns line items of the order found by qr_data' do
        expect(query.call).to eq(line_items)
      end
    end

    context 'when qr_data is not present' do
      before do
        allow(query).to receive(:search_by_guest_name).and_return('guest_name_result')
      end

      it 'returns the result of search_by_guest_name' do
        expect(query.call).to eq('guest_name_result')
      end
    end

    context 'when first_name, last_name, phone_number and taxon_id are present' do
      let(:params) do
        {
          first_name: 'John',
          last_name: 'Doe',
          phone_number: '123456789',
          taxon_id: 1
        }
      end
      let(:guests) { double('guests') }
      let(:line_item_ids) { [1, 2, 3] }
      let(:line_items) { double('line_items') }

      before do
        allow(SpreeCmCommissioner::Guest).to receive(:joins).and_return(guests)
        allow(guests).to receive(:joins).with(line_item: :order).and_return(guests)
        allow(guests).to receive(:where).with('LOWER(cm_guests.first_name) LIKE LOWER(?) AND LOWER(cm_guests.last_name) LIKE LOWER(?)', '%John%', '%Doe%').and_return(guests)
        allow(guests).to receive(:where).with(spree_orders: { phone_number: '123456789' }).and_return(guests)
        allow(guests).to receive(:where).with(parent: { id: 1 }).and_return(guests)
        allow(guests).to receive(:map).and_return(line_item_ids)
        allow(Spree::LineItem).to receive(:where).with(id: line_item_ids).and_return(line_items)
      end

      it 'returns line items found by first_name, last_name, phone_number and taxon_id' do
        expect(query.call).to eq(line_items)
      end
    end
  end
end
