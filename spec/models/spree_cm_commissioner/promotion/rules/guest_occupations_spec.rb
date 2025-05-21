require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::GuestOccupations do
  describe '#eligible?' do

    let(:product1) { create(:cm_product, name: "TedTalk Adult Ticket", kyc: 1 ) }
    let(:product2) { create(:cm_product, name: "TedTalk Student Ticket", kyc:1 ) }

    let(:taxonomy) { create(:taxonomy, kind: :occupation) }

    let(:eligible_occupation1) {  create(:taxon, name: 'Student', taxonomy: taxonomy) }
    let(:eligible_occupation2) {  create(:taxon, name: 'Teacher', taxonomy: taxonomy) }
    let(:ineligible_occupation) { create(:taxon, name: 'Doctor', taxonomy: taxonomy) }

    let(:guest1) { create(:guest) }
    let(:guest2) { create(:guest) }
    let(:guest3) { create(:guest) }
    let(:guest4) { create(:guest) }

    let(:line_item1) { build(:line_item, product: product1, guests:[guest1, guest2]) }
    let(:line_item2) { build(:line_item, product: product2, guests:[guest3, guest4]) }

    let(:order) { create(:order, line_items: [line_item1, line_item2]) }

    context 'match_policy: all' do
      subject { described_class.new(guest_occupations: [eligible_occupation1, eligible_occupation2], preferred_match_policy: 'all') }

      it 'eligible when all guest_occupation in any line-item is from eligible guest_occupations ' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(eligible_occupation1)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(eligible_occupation1)


        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when not all guest_occupation in any line-items is from eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)


        expect(subject.eligible?(order)).to be false
      end


      it 'not eligible when all guest_occupation in any line_items is not in eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match_policy: any' do
      subject { described_class.new(guest_occupations: [eligible_occupation1, eligible_occupation2], preferred_match_policy: 'any') }

      it 'eligible when all guest in any line-items is from eligible guest_occupations ' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(eligible_occupation1)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation2)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(eligible_occupation2)

        expect(subject.eligible?(order)).to be true
      end

      it 'eligible when some guest_occupation in any line-items is from eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when all guest_occupation in any line_items is not in eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match_policy: none' do
      subject { described_class.new(guest_occupations: [eligible_occupation1, eligible_occupation2], preferred_match_policy: 'none') }

      it 'eligible when all guest_occupation in any item_items is not in eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(ineligible_occupation)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when some guest_occupation in any line_items is in eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(ineligible_occupation)

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligible when all guest_occupation in any line_items is in eligble guest_occupations' do

        allow(order.line_items[0].guests.first).to receive(:occupation).and_return(eligible_occupation1)
        allow(order.line_items[0].guests.last).to receive(:occupation).and_return(eligible_occupation1)

        allow(order.line_items[1].guests.first).to receive(:occupation).and_return(eligible_occupation2)
        allow(order.line_items[1].guests.last).to receive(:occupation).and_return(eligible_occupation2)

        expect(subject.eligible?(order)).to be false
      end
    end
  end

  describe '#guest_occupation_ids' do

    let(:taxonomy) { create(:taxonomy, kind: :occupation) }
    let(:eligible_occupation1) {  create(:taxon, name: 'Student', taxonomy: taxonomy) }
    let(:eligible_occupation2) {  create(:taxon, name: 'Teacher', taxonomy: taxonomy) }

    it 'return guest_occupation_ids in array after save ' do
      rule = described_class.new(guest_occupations: [eligible_occupation1, eligible_occupation2], preferred_match_policy: 'none')

      expect(rule.guest_occupation_ids.size).to eq 2
      expect(rule.guest_occupation_ids[0]).to eq eligible_occupation1.id
      expect(rule.guest_occupation_ids[1]).to eq eligible_occupation2.id
    end
  end
end