require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EventTicketAggregatorQuery do
  let(:from_date) { 8.day.from_now }
  let(:to_date) { 11.day.from_now }

  let(:taxonomy) { create(:taxonomy, kind: :event) }
  let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
  let(:taxon_id) { event.id }

  let(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A', from_date: from_date, to_date: to_date) }
  let(:section_b) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B', from_date: from_date, to_date: to_date) }

  let(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
  let(:product_b) { create(:product, product_type: :ecommerce, taxons: [section_b]) }

  before do
    create_orders
    stub_cache
  end

  describe '#call' do
    context 'when taxon_id is valid' do
      it 'should creates a ticket aggregator for the event' do
        query = described_class.new(taxon_id: taxon_id)
        result = query.call

        expect(result).to be_an_instance_of(SpreeCmCommissioner::EventTicketAggregator)
      end

      it 'should caches the result' do
        expect(Rails.cache).to receive(:fetch)
          .with("event-ticket-aggregator-query-#{taxon_id}", expires_in: 5.minutes)
          .and_call_original

        described_class.new(taxon_id: taxon_id).call
      end

      it 'should updates the cache if refreshed' do
        expect(Rails.cache).to receive(:delete)
          .with("event-ticket-aggregator-query-#{taxon_id}")
          .and_call_original

        described_class.new(taxon_id: taxon_id, refreshed: true).call
      end

      it 'should returns data with correct fields' do
        query = described_class.new(taxon_id: taxon_id)
        result = query.call.value

        expect(result).to all(include(:product_id, :total_tickets, :total_items))
      end

      it 'should returns data with correct values' do
        expected_values = [
          { "product_id" => product_a.id, "total_tickets" => 3, "total_items" => 1 },
          { "product_id" => product_b.id, "total_tickets" => 4, "total_items" => 1 }
        ]
        result = described_class.new(taxon_id: event.id).product_aggregators
        expect(result).to eq(expected_values)
      end
    end

    context 'when taxon_id is invalid' do
      let(:invalid_taxon_id) { taxon_id + 1 }

      it 'should returns an empty value array' do
        aggregator_query = described_class.new(taxon_id: invalid_taxon_id)
        aggregators = aggregator_query.call.value

        expect(aggregators).to be_empty
      end
    end
  end

  private

  def create_orders
    create(:classification, taxon: event, product: product_a)
    create(:classification, taxon: event, product: product_b)
    create(:line_item, product: product_a, quantity: 3)
    create(:line_item, product: product_b, quantity: 4)
    create(:completed_order_with_totals, state: :complete, line_items: [product_a.line_items.first, product_b.line_items.first])
  end

  def stub_cache
    allow(Rails.cache).to receive(:fetch).and_yield
    allow(Rails.cache).to receive(:delete)
  end
end
