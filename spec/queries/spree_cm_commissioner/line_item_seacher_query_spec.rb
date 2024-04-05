require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemSearcherQuery do
  describe '#call' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let!(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }

    let!(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A', from_date: Date.current, to_date: Date.current + 2.days) }
    let!(:section_b) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B', from_date: Date.current, to_date: Date.current + 2.days) }

    let!(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
    let!(:product_b) { create(:product, product_type: :ecommerce, taxons: [section_b]) }

    let!(:order) { create(:order, phone_number: '012345678', email: 'lengvevo007@gmail.com', number: 'R591727627', completed_at: Date.current) }

    let!(:line_item1) { create(:cm_line_item, order: order, product: product_a) }
    let!(:line_item2) { create(:cm_line_item, order: order, product: product_b) }

    let!(:guest1) { create(:guest, first_name: 'Han', last_name: 'Xin', line_item: line_item1) }
    let!(:guest2) { create(:guest, first_name: 'Sokleng', last_name: 'Houng', line_item: line_item2) }

    context 'when order qr_data is present' do
      let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXGCUzA1708344610539' } }
      let(:order) { create(:order)}
      let!(:line_item) { create(:cm_line_item, order: order) }

      before do
        allow(Spree::Order).to receive(:search_by_qr_data!).and_return(order)
        allow(order).to receive(:line_items).and_return([line_item])
      end

      it 'calls search_by_qr_data! with qr_data' do
        expect(Spree::Order).to receive(:search_by_qr_data!).with(params[:qr_data])
        described_class.new(params).call
      end

      it 'returns line items of the order found by qr_data' do
        expect(described_class.new(params).call).to eq([line_item])

        expect(order).to have_received(:line_items)
      end

      context 'when order token of qr_data include -L' do
        let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXG-LCUzA1708344610539' } }

        it 'calls search_by_qr_data! with qr_data' do
          expect(Spree::Order).to receive(:search_by_qr_data!).with(params[:qr_data])
          described_class.new(params).call
        end
      end
    end

    context 'when term is present' do
      let(:params) { { term: 'Leng', event_id: event.id } }

      it 'calls search_by_ransack with term' do
        expect(Spree::LineItem).to receive_message_chain(:ransack, :result)
        described_class.new(params).call
      end

      it 'returns line items found by term' do
        expect(described_class.new(params).call.to_a).to eq([line_item2])
      end

      it 'returns line items found by term guest first_name' do
        params[:term] = 'Han'
        expect(described_class.new(params).call.to_a).to eq([line_item1])
      end

      it 'returns line items found by term guest last_name' do
        params[:term] = 'Leng'
        expect(described_class.new(params).call.to_a).to eq([line_item2])
      end

      it 'returns line items found by term order number' do
        params[:term] = 'R591727627'
        expect(described_class.new(params).call.to_a).to eq([line_item1, line_item2])
      end

      it 'returns line items found by term order phone number' do
        params[:term] = '012345678'
        expect(described_class.new(params).call.to_a).to eq([line_item1, line_item2])
      end
    end

    context 'when term email is present' do
      let(:params) { { email: 'lengvevo007@gmail.com' } }

      it 'returns line items found by email' do
        expect(described_class.new(params).call).to eq([line_item1, line_item2])
      end
    end

    context 'when term and qr is not present' do
      it 'calls search_by_guest_infos' do
        expect_any_instance_of(described_class).to receive(:search_by_guest_infos)
        described_class.new({}).call
      end
    end

    context 'when line_item qr_data is line_item' do
      let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXGCUzA1708344610539-L2461' } }
      let(:order) { create(:order)}
      let!(:line_item) { create(:cm_line_item, order: order) }

      before do
        allow(Spree::LineItem).to receive(:search_by_qr_data!).and_return(order)
        allow(order).to receive(:line_items).and_return([line_item])
      end

      it 'calls search_by_qr_data! with qr_data' do
        expect(Spree::LineItem).to receive(:search_by_qr_data!).with(params[:qr_data])
        described_class.new(params).call
      end

      context 'when middle of qr_data include -L' do
        let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXG-LCUzA1708344610539-L2461' } }

        it 'calls search_by_qr_data! with qr_data' do
          expect(Spree::LineItem).to receive(:search_by_qr_data!).with(params[:qr_data])
          described_class.new(params).call
        end
      end
    end
  end
end
