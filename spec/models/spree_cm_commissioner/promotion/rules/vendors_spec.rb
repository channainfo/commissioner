require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::Vendors do
  describe '#eligible?' do
    let(:eligible_vendor1) { create(:vendor) }
    let(:eligible_vendor2) { create(:vendor) }
    let(:ineligible_vendor) { create(:vendor) }
    let(:order) { create(:order_with_line_items, line_items_count: 2) }

    context 'match_policy: all' do
      subject { described_class.new(vendors: [eligible_vendor1, eligible_vendor2], preferred_match_policy: 'all') }

      it 'eligible when all line items is from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(eligible_vendor2)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when some line items is not from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligible when some line items is not from eligible vendors' do
        order = create(:order_with_line_items, line_items_count: 3)

        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(eligible_vendor2)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligible when all line items is not from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(ineligible_vendor)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match_policy: any' do
      subject { described_class.new(vendors: [eligible_vendor1, eligible_vendor2], preferred_match_policy: 'any') }

      it 'eligible when some line items is from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be true
      end

      it 'eligible when all line items is from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(eligible_vendor2)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when all line items is not from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(ineligible_vendor)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match_policy: none' do
      subject { described_class.new(vendors: [eligible_vendor1, eligible_vendor2], preferred_match_policy: 'none') }

      it 'eligible when all line items is not from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(ineligible_vendor)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when some line items is from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(ineligible_vendor)

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligible when all line items is from eligible vendors' do
        allow(order.line_items[0]).to receive(:vendor).and_return(eligible_vendor1)
        allow(order.line_items[1]).to receive(:vendor).and_return(eligible_vendor2)

        expect(subject.eligible?(order)).to be false
      end
    end
  end

  describe '#vendor_ids' do
    let(:eligible_vendor1) { create(:vendor) }
    let(:eligible_vendor2) { create(:vendor) }

    it 'return vendor ids in array after save' do
      rule = described_class.create(vendors: [eligible_vendor1, eligible_vendor2], preferred_match_policy: 'all')

      expect(rule.vendor_ids.size).to eq 2
      expect(rule.vendor_ids[0]).to eq eligible_vendor1.id
      expect(rule.vendor_ids[1]).to eq eligible_vendor2.id
    end
  end
end
