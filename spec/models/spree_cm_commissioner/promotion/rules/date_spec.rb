require 'spec_helper'

# test here so sub-class only need to test date_eligible? method.
RSpec.describe SpreeCmCommissioner::Promotion::Rules::Date do
  let!(:klass) { Class.new(described_class) }
  subject { klass.new }

  describe '#applicable?(order)' do
    let!(:order) { create(:order_with_line_items, line_items_count: 2) }

    it 'not applicable when all line items does not has duration' do
      allow(order.line_items[0]).to receive(:date_present?).and_return(false)
      allow(order.line_items[1]).to receive(:date_present?).and_return(false)

      expect(subject.applicable?(order)).to be false
    end

    it 'applicable when some of line items has duration' do
      allow(order.line_items[0]).to receive(:date_present?).and_return(true)
      allow(order.line_items[1]).to receive(:date_present?).and_return(false)

      expect(subject.applicable?(order)).to be true
    end

    it 'applicable when all of line items has duration' do
      allow(order.line_items[0]).to receive(:date_present?).and_return(true)
      allow(order.line_items[1]).to receive(:date_present?).and_return(true)

      expect(subject.applicable?(order)).to be true
    end
  end

  describe '#eligible?(order, options = {})' do
    context 'match policy: all' do
      let!(:order) { create(:order_with_line_items, line_items_count: 2) }

      before do
        allow(subject).to receive(:preferred_match_policy).and_return('all')
      end

      it 'eligible when all line items are eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(true)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(true)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when some line items are not eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(true)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(false)

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligible when all line items are not eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(false)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(false)

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match policy: any' do
      let!(:order) { create(:order_with_line_items, line_items_count: 2) }

      before do
        allow(subject).to receive(:preferred_match_policy).and_return('any')
      end

      it 'eligible when some line items are eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(true)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(false)

        expect(subject.eligible?(order)).to be true
      end

      it 'eligible when all line items are eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(true)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(true)

        expect(subject.eligible?(order)).to be true
      end

      it 'eligible when all line items are not eligible' do
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[0]).and_return(false)
        allow(subject).to receive(:line_item_eligible?).with(order.line_items[1]).and_return(false)

        expect(subject.eligible?(order)).to be false
      end
    end
  end

  describe '#line_item_eligible?(line_item)' do
    let(:date1) { '2023-01-10'.to_date }
    let(:date2) { '2023-01-11'.to_date }

    let!(:line_item) { create(:line_item, from_date: date1, to_date: date2) }

    it 'eligible when any date of date range are eligible' do
      allow(subject).to receive(:date_eligible?).with(date1).and_return(true)
      allow(subject).to receive(:date_eligible?).with(date2).and_return(false)

      expect(subject.line_item_eligible?(line_item)).to be true
    end

    it 'eligible when all date of date range are eligible' do
      allow(subject).to receive(:date_eligible?).with(date1).and_return(true)
      allow(subject).to receive(:date_eligible?).with(date2).and_return(true)

      expect(subject.line_item_eligible?(line_item)).to be true
    end

    it 'not eligible when all date of date range are not eligible' do
      allow(subject).to receive(:date_eligible?).with(date1).and_return(false)
      allow(subject).to receive(:date_eligible?).with(date2).and_return(false)

      expect(subject.line_item_eligible?(line_item)).to be false
    end

    it 'not eligible when line item does not has date range' do
      allow(line_item).to receive(:from_date).and_return(nil)
      allow(line_item).to receive(:to_date).and_return(nil)

      expect(subject.line_item_eligible?(line_item)).to be false
    end
  end

  describe '#actionable?' do
    let!(:line_item) { create(:line_item) }

    it 'return actionable? true when line_item_eligible? is true' do
      allow(subject).to receive(:line_item_eligible?).with(line_item).and_return(true)

      expect(subject.actionable?(line_item)).to be true
    end

    it 'return actionable? false when line_item_eligible? is false' do
      allow(subject).to receive(:line_item_eligible?).with(line_item).and_return(false)

      expect(subject.actionable?(line_item)).to be false
    end
  end

  describe '#date_eligible?' do
    it 'raise error when sub-class does not override' do
      expect { subject.date_eligible?('2023-01-10'.to_date) }
        .to raise_error(RuntimeError)
        .with_message("date_eligible? should be implemented in a sub-class of SpreeCmCommissioner::Promotion::Rules::Date")
    end
  end
end
