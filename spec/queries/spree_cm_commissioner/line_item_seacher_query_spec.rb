require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemSearcherQuery do
  describe '#call' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let!(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }

    let!(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A', from_date: Date.current, to_date: Date.current + 2.days) }
    let!(:section_b) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B', from_date: Date.current, to_date: Date.current + 2.days) }

    let!(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
    let!(:product_b) { create(:product, product_type: :ecommerce, taxons: [section_b]) }

    let!(:order) { create(:order, phone_number: '012345678', email: 'lengvevo007@gmail.com', number: 'R591727627', completed_at: Date.current, token: 'WiWma0OjZqh7Tk1aXGCUzA1708344610539') }

    let!(:line_item1) { create(:cm_line_item, order: order, product: product_a) }
    let!(:line_item2) { create(:cm_line_item, order: order, product: product_b) }

    let!(:guest1) { create(:guest, first_name: 'Han', last_name: 'Xin', line_item: line_item1) }
    let!(:guest2) { create(:guest, first_name: 'Sokleng', last_name: 'Houng', line_item: line_item2) }

    context 'when order qr_data is present' do
      let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXGCUzA1708344610539' } }

      it 'calls search_by_qr_data! with qr_data' do
        expect(Spree::Order).to receive(:search_by_qr_data!).with(params[:qr_data]).and_return(order)
        described_class.new(params).call
      end

      it 'returns line item of the order found by qr_data' do
        result = described_class.new(params).call
        expect(result).to eq([line_item1, line_item2])
      end

      context 'when order token of qr_data include -L' do
        let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXG-LCUzA1708344610539' } }

        it 'calls search_by_qr_data! with qr_data' do
          expect(Spree::Order).to receive(:search_by_qr_data!).with(params[:qr_data]).and_return(order)
          described_class.new(params).call
        end
      end
    end

    context 'when line_item qr_data is present' do
      let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXGCUzA1708344610539-L2461' } }
      let(:order) { create(:order)}
      let!(:line_item) { create(:cm_line_item, order: order) }

      it 'calls search_by_qr_data! with qr_data' do
        expect(Spree::LineItem).to receive(:search_by_qr_data!).with(params[:qr_data]).and_return(line_item)
        described_class.new(params).call
      end

      context 'when middle of qr_data include -L' do
        let(:params) { { qr_data: 'R591727627-WiWma0OjZqh7Tk1aXG-LCUzA1708344610539-L2461' } }

        it 'calls search_by_qr_data! with qr_data' do
          expect(Spree::LineItem).to receive(:search_by_qr_data!).with(params[:qr_data]).and_return(line_item)
          described_class.new(params).call
        end
      end
    end

    context 'when term is present' do
      let(:params) { { term: 'Han', event_id: event.id } }

      it 'calls search_by_ransack' do
        expect_any_instance_of(described_class).to receive(:search_by_ransack)
        described_class.new(params).call
      end

      it 'returns line items that match the term order number' do
        params[:term] = 'R591727627'
        result = described_class.new(params).call
        expect(result).to eq([line_item1, line_item2])
      end

      it 'returns line items that match the term guest first name' do
        params[:term] = 'Sokleng'
        result = described_class.new(params).call
        expect(result).to eq([line_item2])
      end

      it 'returns line items that match the term guest last name' do
        params[:term] = 'Xin'
        result = described_class.new(params).call
        expect(result).to eq([line_item1])
      end

      it 'returns line items that match the term order phone number' do
        params[:term] = '012345678'
        result = described_class.new(params).call
        expect(result).to eq([line_item1, line_item2])
      end
    end

    context 'when guest qr_data is present' do
      before do
        ENV['GUEST_TOKEN'] = 'aa242f4c-c53e-4e91-bd3c-afa84d3ed722'
      end
      let(:line_item) { create(:cm_line_item, order: order) }
      let(:guest) { create(:guest, token: ENV['GUEST_TOKEN'], line_item: line_item) }
      let(:params) { { qr_data: guest.token } }

      it 'calls find_by with qr_data' do
        expect(SpreeCmCommissioner::Guest).to receive(:find_by!).with(token: params[:qr_data]).and_return(guest)
        described_class.new(params).call
      end

      it 'returns line item of the guest found by qr_data' do
        result = described_class.new(params).call
        expect(result).to eq([line_item])
      end
    end
  end
end
