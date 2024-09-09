require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PieChartEventAggregatorQueries do
  let(:taxon_id) { 74 }
  let(:chart_type) { 'participation' }
  let(:refreshed) { false }

  subject { described_class.new(taxon_id: taxon_id, chart_type: chart_type, refreshed: refreshed) }

  describe '#call' do
    context 'when taxon_id is valid' do
      it 'should creates a pie chart aggregator for the event' do
        result = subject.call
        expect(result).to be_an_instance_of(SpreeCmCommissioner::PieChartEventAggregator)
      end

      it 'should caches the result' do
        expect(Rails.cache).to receive(:fetch)
          .with("#{chart_type}-#{taxon_id}", expires_in: 30.minutes)
        subject.call
      end

      it 'should updates the cache if refreshed' do
        refreshed_instance = described_class.new(taxon_id: taxon_id, chart_type: chart_type, refreshed: true)
        expect(Rails.cache).to receive(:delete)
          .with("#{chart_type}-#{taxon_id}")
          .and_call_original
        refreshed_instance.call
      end

      context 'when chart type is participation' do
        let(:chart_type) { 'participation' }
        let(:mock_value) do
          [
            { product_id: 1, checked_in_ticket: 3, total_ticket: 5 },
            { product_id: 2, checked_in_ticket: 2, total_ticket: 4 }
          ]
        end

        before do
          allow(subject).to receive(:call).and_return(OpenStruct.new(value: mock_value))
        end

        it 'should returns data with correct fields' do
          result = subject.call.value
          expect(result).to all(include(:product_id, :checked_in_ticket, :total_ticket))
        end
      end

      context 'when chart type is gender' do
        let(:chart_type) { 'gender' }
        let(:mock_value) do
          [
            { genders: 'female', gender_count: 2 },
            { genders: 'male', gender_count: 1 }
          ]
        end

        before do
          allow(subject).to receive(:call).and_return(OpenStruct.new(value: mock_value))
        end

        it 'should returns data with correct fields' do
          result = subject.call.value
          expect(result).to all(include(:genders, :gender_count))
        end
      end

      context 'when chart type is entry_type' do
        let(:chart_type) { 'entry_type' }
        let(:mock_value) do
          [
            { product_id: 1, entry_types: 'normal', check_in_count: 5 },
            { product_id: 2, entry_types: 'VIP', check_in_count: 3 }
          ]
        end

        before do
          allow(subject).to receive(:call).and_return(OpenStruct.new(value: mock_value))
        end

        it 'should returns data with correct fields' do
          result = subject.call.value
          expect(result).to all(include(:product_id, :entry_types, :check_in_count))
        end
      end
    end
  end
end
