require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CreateTicket, type: :interactor do
  let(:taxonomy) { create(:taxonomy, name: 'Events', kind: :event) }
  let(:event) { create(:taxon, taxonomy: taxonomy, name: 'BunPhum') }
  let(:section) { create(:taxon, name: 'Ticket Type', taxonomy: taxonomy, parent: event) }

  let!(:store) { create(:store, default: true) }
  let!(:shipping_category) { create(:shipping_category) }
  let!(:stock_location) { create(:stock_location) }
  let!(:vendor) { create(:cm_vendor) }

  let(:base_params) do
    {
      name: 'Test Ticket',
      price: 123,
      count_on_hand: 500,
      max_order_quantity: 5,
      option_type_ids: [],
      vendor_id: vendor.id,
      product_type: 'ecommerce',
      shipping_category_id: shipping_category.id,
      stock_location_id: stock_location.id,
      event_id: event.event_slug,
      action: 'create'
    }
  end

  before do
    event.children = [section]
    event.save!
    event.reload
  end

  describe 'Ticket creation' do
    it 'creates a ticket with correct attributes' do

      result = described_class.call(params: base_params)
      ticket = Spree::Product.last

      expect(result).to be_success
      expect(ticket.name).to eq('Test Ticket')
      expect(ticket.price.to_f).to eq(123.0)
      expect(ticket.vendor_id).to eq(vendor.id)
    end
  end

  describe 'Store assignment' do
    it 'assigns the default store to the ticket' do

      described_class.call(params: base_params)
      ticket = Spree::Product.last

      expect(ticket.stores).to include(store)
    end
  end

  describe 'Event assignment' do
    context 'when event exists' do
      it 'assigns the section taxon to the ticket' do

        described_class.call(params: base_params)
        ticket = Spree::Product.last

        expect(ticket.taxons).to include(section)
      end
    end

    context 'when event does not exist' do
      it 'fails with appropriate message' do

        invalid_params = base_params.merge(event_id: 'unknown')
        result = described_class.call(params: invalid_params)

        expect(result).to be_failure
        expect(result.message).to eq('Event not found.')
      end
    end
  end

  describe 'Variant creation' do
    it 'creates a variant for the ticket' do
      described_class.call(params: base_params)
      ticket = Spree::Product.last
      variant = ticket.variants.first

      expect(variant).to be_present
      expect(variant.price.to_f).to eq(ticket.price.to_f)
    end
  end

  describe 'Stock item creation' do
    it 'creates a stock item for the variant' do
      described_class.call(params: base_params)
      variant = Spree::Product.last.variants.first
      stock_item = variant.stock_items.first

      expect(stock_item).to be_present
      expect(stock_item.count_on_hand).to eq(500)
    end
  end
end
