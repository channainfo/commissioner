require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryFetcher do
  let(:variant_ids) { [1, 2, 3] }
  let(:params) { {} }
  let(:product_type) { 'accommodation' }
  let(:context) { Interactor::Context.new(variant_ids: variant_ids, params: params, product_type: product_type) }

  subject { described_class.new(context) }

  before do
    allow(subject).to receive(:context).and_return(context)
  end

  describe '#call' do
    context 'when validation fails' do
      let(:variant_ids) { [] }

      it 'fails with missing variant_ids message' do
        expect{subject.call}.to raise_error(Interactor::Failure)
      end
    end

    context 'with valid params' do
      let(:params) { {check_in: Date.today.to_s, check_out: Date.tomorrow.to_s, num_guests: 1} }
      let(:inventory_service) { double('InventoryService', fetch_inventory: ['inventory_results']) }

      before do
        allow(subject).to receive(:inventory_service).and_return(inventory_service)
      end

      it 'sets context results from inventory service' do
        expect(context).to receive(:results=).with(['inventory_results'])
        subject.call
      end
    end
  end

  describe '#inventory_service' do
    context 'for accommodation product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION }
      let(:params) { { check_in: '2025-04-01', check_out: '2025-04-03', num_guests: '2' } }

      it 'returns an AccommodationInventory instance with correct params' do
        service = subject.send(:inventory_service)
        expect(service).to be_a(SpreeCmCommissioner::AccommodationInventory)
        expect(service.variant_ids).to eq(variant_ids)
        expect(service.check_in).to eq(Date.parse('2025-04-01'))
        expect(service.check_out).to eq(Date.parse('2025-04-03'))
        expect(service.num_guests).to eq(2)
      end
    end

    context 'for bus product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS }
      let(:params) { { trip_date: '2025-04-02' } }

      it 'returns a BusInventory instance with correct params' do
        service = subject.send(:inventory_service)
        expect(service).to be_a(SpreeCmCommissioner::BusInventory)
        expect(service.variant_ids).to eq(variant_ids)
        expect(service.trip_date).to eq(Date.parse('2025-04-02'))
      end
    end

    context 'for event product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT }
      let(:params) { {} }

      it 'returns an EventInventory instance with correct params' do
        service = subject.send(:inventory_service)
        expect(service).to be_a(SpreeCmCommissioner::EventInventory)
        expect(service.variant_ids).to eq(variant_ids)
      end
    end

    context 'for unknown product type' do
      let(:product_type) { 'unknown' }

      it 'returns nil' do
        expect(subject.send(:inventory_service)).to be_nil
      end
    end
  end

  describe '#validate_params!' do
    context 'with missing variant_ids' do
      let(:variant_ids) { [] }

      it 'fails with appropriate message' do
        expect(context).to receive(:fail!).with(message: 'Variant IDs are required')
        subject.send(:validate_params!)
      end
    end

    context 'with missing product_type' do
      let(:product_type) { nil }

      it 'fails with appropriate message' do
        expect(context).to receive(:fail!).with(message: 'Product type is required')
        subject.send(:validate_params!)
      end
    end

    context 'with accommodation product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION }

      context 'with all required params' do
        let(:params) { { check_in: '2025-04-01', check_out: '2025-04-03', num_guests: '2' } }

        it 'does not fail' do
          expect(context).not_to receive(:fail!)
          subject.send(:validate_params!)
        end
      end

      context 'with missing check_in' do
        let(:params) { { check_out: '2025-04-03', num_guests: '2' } }

        it 'fails with missing params message' do
          expect(context).to receive(:fail!).with(message: "Missing required parameters for product type '#{product_type}'")
          subject.send(:validate_params!)
        end
      end
    end

    context 'with bus product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS }

      context 'with trip_date' do
        let(:params) { { trip_date: '2025-04-02' } }

        it 'does not fail' do
          expect(context).not_to receive(:fail!)
          subject.send(:validate_params!)
        end
      end

      context 'with missing trip_date' do
        let(:params) { {} }

        it 'fails with missing params message' do
          expect(context).to receive(:fail!).with(message: "Missing required parameters for product type '#{product_type}'")
          subject.send(:validate_params!)
        end
      end
    end

    context 'with event product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT }
      let(:params) { {} }

      it 'does not fail even with no params' do
        expect(context).not_to receive(:fail!)
        subject.send(:validate_params!)
      end
    end

    context 'with unknown product type' do
      let(:product_type) { 'unknown' }
      let(:params) { {} }

      it 'fails with missing params message' do
        expect(context).to receive(:fail!).with(message: "Missing required parameters for product type 'unknown'")
        subject.send(:validate_params!)
      end
    end
  end

  describe '#invalid_fetching_params?' do
    context 'with accommodation product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION }

      it 'returns false when all params present' do
        params.merge!(check_in: '2025-04-01', check_out: '2025-04-03', num_guests: '2')
        expect(subject.send(:invalid_fetching_params?)).to be false
      end

      it 'returns true when check_in is missing' do
        params.merge!(check_out: '2025-04-03', num_guests: '2')
        expect(subject.send(:invalid_fetching_params?)).to be true
      end
    end

    context 'with bus product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS }

      it 'returns false when trip_date present' do
        params.merge!(trip_date: '2025-04-02')
        expect(subject.send(:invalid_fetching_params?)).to be false
      end

      it 'returns true when trip_date missing' do
        expect(subject.send(:invalid_fetching_params?)).to be true
      end
    end

    context 'with event product type' do
      let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT }

      it 'returns false regardless of params' do
        expect(subject.send(:invalid_fetching_params?)).to be false
      end
    end

    context 'with unknown product type' do
      let(:product_type) { 'unknown' }

      it 'returns true' do
        expect(subject.send(:invalid_fetching_params?)).to be true
      end
    end
  end
end
