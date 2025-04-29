require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::LineItemAvailabilityChecker do
  let(:variant) { create(:cm_variant) }
  let(:line_item) { create(:line_item, variant: variant) }
  let(:checker_klass) { SpreeCmCommissioner::Stock::AvailabilityChecker }
  let(:checker) { checker_klass.new(variant) }

  subject { described_class.new(line_item) }

  describe '#can_supply?' do
    it 'construct AvailabilityChecker & call can_supply? with options' do
      expect(checker_klass).to receive(:new).with(line_item.variant, subject.options).and_return(checker)
      expect(checker).to receive(:can_supply?).with(5)

      subject.can_supply?(5)
    end
  end

  describe '#options' do
    it 'returns the correct options hash' do
      expected_options = { from_date: line_item.from_date, to_date: line_item.to_date }

      expect(subject.options).to eq expected_options
    end
  end
end
