require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Actions::CreateDateSpecificItemAdjustments do
  let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), permanent_stock: 4) }
  let(:order) { create(:order) }
  let(:line_item_10_to_12) {
    create(:line_item,
      order: order,
      quantity: 1,
      price: BigDecimal('10.0'),
      product: product,
      from_date: '2023-01-10'.to_date,
      to_date: '2023-01-13'.to_date
    )
  }

  let(:ten_percent_off_calculator) { Spree::Calculator::PercentOnLineItem.new(preferred_percent: 10) }
  let(:line_item_13_to_14) {
    create(:line_item,
      order: order,
      quantity: 1,
      price: BigDecimal('10.0'),
      product: product,
      from_date: '2023-01-13'.to_date,
      to_date: '2023-01-15'.to_date
    )
  }

  # 12 - 14
  let(:rule) {
    SpreeCmCommissioner::Promotion::Rules::FixedDate.create(
      preferred_start_date: '2023-01-12'.to_date,
      preferred_length: 3,
      preferred_match_policy: 'any',
    )
  }

  let!(:promotion) { create(:promotion, promotion_rules: [rule]) }

  describe '#compute_line_item_amount' do
    it 'return computed amount of -10% = 1$ for a matched date: 2023-01-12' do
      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.compute_line_item_amount(line_item_10_to_12)

      expect(amount).to eq (1.0)
      expect(-amount).to eq (subject.compute_amount(line_item_10_to_12))
    end

    it 'return computed amount of -10% = 2$ for 2 matched dates: 2023-01-13, 2023-01-14' do
      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.compute_line_item_amount(line_item_13_to_14)

      expect(amount).to eq (2.0)
      expect(-amount).to eq (subject.compute_amount(line_item_13_to_14))
    end
  end

  describe '#perform' do
    it 'create a (-10% = 1$) adjustment for a matched date: 2023-01-12' do
      line_item_10_to_12

      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.perform(order: order, promotion: promotion)

      expect(subject.adjustments.size).to eq 1
      expect(subject.adjustments[0].adjustable).to eq line_item_10_to_12
      expect(subject.adjustments[0].amount).to eq -1.0
    end

    it 'create two adjustments for 2 line items on 3 matched date: 2023-01-12, 2023-01-13, 2023-01-14' do
      line_item_10_to_12
      line_item_13_to_14

      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.perform(order: order, promotion: promotion)

      expect(subject.adjustments.size).to eq 2

      expect(subject.adjustments[0].adjustable).to eq line_item_10_to_12
      expect(subject.adjustments[0].amount).to eq -1.0

      expect(subject.adjustments[1].adjustable).to eq line_item_13_to_14
      expect(subject.adjustments[1].amount).to eq -2.0
    end
  end
end