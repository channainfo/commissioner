require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Actions::CreateGuestItemAdjustments do

  let(:product) { create(:product, name: "TedTalk Adult Ticket", price: BigDecimal('10.0'), kyc: 1 ) }

  let(:taxonomy) { create(:taxonomy, kind: :occupation) }
  let(:occupation) {  create(:taxon, name: 'Student', taxonomy: taxonomy) }
  let(:occupation2) {  create(:taxon, name: 'Doctor', taxonomy: taxonomy) }

  let(:guest1) { create(:guest , occupation_id: occupation.id) }
  let(:guest2) { create(:guest , occupation_id: occupation.id) }
  let(:guest3) { create(:guest , occupation_id: occupation.id) }

  let(:guest4) { create(:guest , occupation_id: occupation2.id) }

  let(:order) { create(:order) }

  let(:ten_percent_off_calculator) { Spree::Calculator::PercentOnLineItem.new(preferred_percent: 10) }

  let(:line_item_with_1_guest) {
    create(:line_item,
      order: order,
      quantity: 1,
      price: BigDecimal('10.0'),
      product: product,
      guests: [guest1],
    )
  }

  let(:line_item_with_2_guest) {
    create(:line_item,
      order: order,
      quantity: 2,
      price: BigDecimal('10.0'),
      product: product,
      guests: [guest2,guest3]
    )
  }

  let(:line_item_with_only_1_guest_eligable) {
    create(:line_item,
      order: order,
      quantity: 2,
      price: BigDecimal('10.0'),
      product: product,
      guests: [guest2,guest4]
    )
  }

  let(:rule) {
    SpreeCmCommissioner::Promotion::Rules::GuestOccupations.create(
      guest_occupations: [occupation],
      preferred_match_policy: 'all',
    )
  }

  let(:rule2) {
    SpreeCmCommissioner::Promotion::Rules::GuestOccupations.create(
      guest_occupations: [occupation],
      preferred_match_policy: 'any',
    )
  }

  let!(:promotion) { create(:promotion, promotion_rules: [rule]) }
  let!(:promotion2) { create(:promotion, promotion_rules: [rule2]) }

  describe '#compute_line_item_amount' do
    context '#match_policy: all' do
      it 'return computed amount of -10% = 1$ for 1 guest match with selected occupation' do
        subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
        amount = subject.compute_line_item_amount(line_item_with_1_guest)

        expect(amount).to eq (1.0)
        expect(-amount).to eq (subject.compute_amount(line_item_with_1_guest))
      end
      it 'return computed amount of -10% = 2$ for 2 guest match with selected occupation' do
        subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
        amount = subject.compute_line_item_amount(line_item_with_2_guest)

        expect(amount).to eq (2.0)
        expect(-amount).to eq (subject.compute_amount(line_item_with_2_guest))
      end
    end
    context '#match_policy: any' do
      it 'return computed amount of -10% = 1$ if only 1 guest match with selectd occupation' do
        subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion2)
        amount = subject.compute_line_item_amount(line_item_with_only_1_guest_eligable)

        expect(amount).to eq (1.0)
        expect(-amount).to eq (subject.compute_amount(line_item_with_only_1_guest_eligable))
      end
    end
  end

  describe '#perform' do
    it 'create a (-10% = 1$) adjustment for a guest matched with selected occupation' do
      line_item_with_1_guest

      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.perform(order: order, promotion: promotion)

      expect(subject.adjustments.size).to eq 1
      expect(subject.adjustments[0].adjustable.id).to eq line_item_with_1_guest.id
      expect(subject.adjustments[0].amount).to eq -1.0
    end

    it 'create 2 adjustments for 2 line items for guests matched with selected occupation' do
      line_item_with_1_guest
      line_item_with_2_guest

      subject = described_class.new(calculator: ten_percent_off_calculator, promotion: promotion)
      amount = subject.perform(order: order, promotion: promotion)

      expect(subject.adjustments.size).to eq 2

      expect(subject.adjustments[0].adjustable.id).to eq line_item_with_1_guest.id
      expect(subject.adjustments[0].amount).to eq -1.0

      expect(subject.adjustments[1].adjustable.id).to eq line_item_with_2_guest.id
      expect(subject.adjustments[1].amount).to eq -2.0
   end
  end
end