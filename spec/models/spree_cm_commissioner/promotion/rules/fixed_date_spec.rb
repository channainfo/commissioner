require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::FixedDate do
  let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), permanent_stock: 4) }
  let(:order) { create(:order) }
  let(:line_item_10_to_12) {
    create(:line_item,
      order: order,
      quantity: 1,
      product: product,
      from_date: '2023-01-10'.to_date,
      to_date: '2023-01-12'.to_date
    )
  }

  let(:normal_line_item) {
    create(:line_item,
      order: order,
      quantity: 1,
      product: product
    )
  }

  describe '#applicable?' do
    it 'applicable when any of line items has date range present?' do
      subject = described_class.new

      expect(subject.applicable?(line_item_10_to_12.order))
      expect(order.line_items.any?(&:date_present?)).to be true
    end
  end

  describe '#line_item_eligible?' do
    it 'eligible when any dates between from_date to end_date of line items is 2023-01-11 or 2023-01-12' do
      subject = described_class.new(
        preferred_start_date: '2023-01-11'.to_date,
        preferred_length: 2,
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be true
    end

    it 'not eligible when no dates between from_date to end_date of line items is 2023-01-13 or 2023-01-14' do
      subject = described_class.new(
        preferred_start_date: '2023-01-13'.to_date,
        preferred_length: 2,
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be false
    end
  end

  describe '#actionable?' do
    it 'eligible when line item is eligible' do
      subject = described_class.new(preferred_start_date: '2023-01-11'.to_date, preferred_length: 2)

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be true
      expect(subject.actionable?(line_item_10_to_12)).to be true
    end
  end

  describe '#eligible?' do
    it 'eligible when all of line item are eligible' do
      # eligible from 2023-01-12 to 2023-01-13
      subject = described_class.new(
        preferred_start_date: '2023-01-12'.to_date,
        preferred_length: 2,
        preferred_match_policy: 'all',
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be true
      expect(subject.eligible?(order)).to be true

      expect(order.line_items.size).to eq 1
    end

    it 'not eligible when not all of line items are eligible' do
      # eligible only on 2023-01-12
      subject = described_class.new(
        preferred_start_date: '2023-01-12'.to_date,
        preferred_length: 1,
        preferred_match_policy: 'all',
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be true
      expect(subject.line_item_eligible?(normal_line_item)).to be false
      expect(subject.eligible?(order)).to be false

      expect(order.line_items.size).to eq 2
    end

    it 'eligible when any of line items are eligible' do
      # eligible only on 2023-01-12
      subject = described_class.new(
        preferred_start_date: '2023-01-12'.to_date,
        preferred_length: 1,
        preferred_match_policy: 'any',
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be true
      expect(subject.line_item_eligible?(normal_line_item)).to be false
      expect(subject.eligible?(order)).to be true
    end

    it 'not eligible when any of line items are not eligible' do
      # eligible only on 2023-01-12
      subject = described_class.new(
        preferred_start_date: '2023-01-08'.to_date,
        preferred_length: 1,
        preferred_match_policy: 'any',
      )

      expect(subject.line_item_eligible?(line_item_10_to_12)).to be false
      expect(subject.line_item_eligible?(normal_line_item)).to be false
      expect(subject.eligible?(order)).to be false
    end
  end
end