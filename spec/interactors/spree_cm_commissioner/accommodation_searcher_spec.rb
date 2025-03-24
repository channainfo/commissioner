require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccommodationSearcher do
  describe '#call' do
    let(:context) { Interactor::Context.new(params: params, properties: {}, is_detail: false) }
    let(:searcher) { described_class.new(context) }
    let(:params) { { per_page: '10', page: '1' } }
    let(:accommodation_search) { double('AccommodationSearch') }

    before do
      allow(searcher).to receive(:accommodation_query).and_return(accommodation_search)
      allow(context).to receive(:value=)
    end

    context 'when is_detail is false' do
      let(:paginated_result) { double('PaginatedResult') }

      it 'returns paginated results' do
        allow(searcher).to receive(:page).and_return(1)
        allow(searcher).to receive(:per_page).and_return(10)
        allow(accommodation_search).to receive(:page).with(1).and_return(accommodation_search)
        allow(accommodation_search).to receive(:per).with(10).and_return(paginated_result)

        searcher.call
        expect(context).to have_received(:value=).with(paginated_result)
      end
    end

    context 'when is_detail is true' do
      let(:single_result) { double('SingleResult') }
      before { context.is_detail = true }

      it 'returns first result' do
        allow(accommodation_search).to receive(:first).and_return(single_result)

        searcher.call
        expect(context).to have_received(:value=).with(single_result)
      end
    end
  end

  describe '#accommodation_query' do
    let(:context) do
      Interactor::Context.new(
        params: {},
        properties: {
          from_date: Date.today,
          to_date: Date.tomorrow,
          province_id: 1,
          vendor_id: 2,
          num_guests: 3
        }
      )
    end
    let(:searcher) { described_class.new(context) }
    let(:search_obj) { double('AccommodationSearch') }

    it 'creates AccommodationSearch with correct parameters' do
      expect(SpreeCmCommissioner::AccommodationSearch).to receive(:new).with(
        from_date: Date.today,
        to_date: Date.tomorrow,
        province_id: 1,
        vendor_id: 2,
        num_guests: 3
      ).and_return(search_obj)

      expect(search_obj).to receive(:with_available_inventory)
      searcher.accommodation_query
    end
  end

  describe '#method_missing' do
    let(:context) { Interactor::Context.new(params: {}, properties: { test_key: 'value' }) }
    let(:searcher) { described_class.new(context) }

    it 'returns property value when key exists' do
      expect(searcher.test_key).to eq('value')
    end

    it 'raises NoMethodError when key does not exist' do
      expect { searcher.unknown_key }.to raise_error(NoMethodError)
    end
  end

  describe '#check_is_detail' do
    let(:context) { Interactor::Context.new(params: params, properties: {}) }
    let(:searcher) { described_class.new(context) }
    let(:vendor) { double('Vendor', id: 123) }

    context 'with id param' do
      let(:params) { { id: 'vendor-slug' } }

      it 'sets is_detail and vendor_id' do
        allow(Spree::Vendor).to receive(:find_by).with(slug: 'vendor-slug').and_return(vendor)
        searcher.send(:check_is_detail)

        expect(context.is_detail).to be true
        expect(context.properties[:vendor_id]).to eq(123)
      end
    end

    context 'without id param' do
      let(:params) { {} }

      it 'sets is_detail to false' do
        searcher.send(:check_is_detail)
        expect(context.is_detail).to be false
        expect(context.properties[:vendor_id]).to be_nil
      end
    end
  end

  describe '#prepare_params' do
    let(:context) { Interactor::Context.new(params: params, properties: {}) }
    let(:searcher) { described_class.new(context) }
    let(:params) do
      {
        province_id: '1',
        from_date: '2023-01-01',
        to_date: '2023-01-02',
        num_guests: '2',
        adult: '2',
        children: '1',
        room_qty: '1',
        per_page: '15',
        page: '2'
      }
    end

    it 'sets up properties correctly' do
      allow(Spree::Config).to receive(:[]).with(:products_per_page).and_return(25)
      passenger_option = double('PassengerOption')
      expect(SpreeCmCommissioner::PassengerOption).to receive(:new)
        .with(adult: '2', children: '1', room_qty: '1')
        .and_return(passenger_option)

      searcher.send(:prepare_params)

      expect(context.properties).to eq(
        province_id: '1',
        from_date: Date.parse('2023-01-01'),
        to_date: Date.parse('2023-01-02'),
        num_guests: 2,
        passenger_options: passenger_option,
        per_page: 15,
        page: 2
      )
    end
  end
end
