require 'spec_helper'
require 'timecop'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::GuestAges do
  describe '#eligible?' do
    let(:product) { create(:product, name: "TedTalk Adult Ticket", kyc: 1 ) }
    let(:taxonomy) { create(:taxonomy, kind: :occupation) }

    let(:guest1) { create(:guest ,dob: 17.years.ago) }
    let(:guest2) { create(:guest ,dob: 19.years.ago) }

    let(:line_item1) { build(:line_item, product: product, guests:[guest1, guest2]) }

    let(:order) { create(:order, line_items: [line_item1]) }

    let(:unmatch_age) { 30 }

    before do
      Timecop.freeze(Time.utc(2023, 1, 23))
    end

    context 'match_policy: all' do

      it 'eligble when guest current age include in selected guest_ages' do
        subject = described_class.new(preferred_match_policy: 'all', preferred_guest_ages: [17,19])

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when guest current age is not include in selected guest_ages' do
        subject = described_class.new( preferred_match_policy: 'all', preferred_guest_ages: [unmatch_age])

        expect(subject.eligible?(order)).to be false
      end

      it 'not eligble when all guests is not include in selected guest_ages' do
        subject = described_class.new(preferred_match_policy: 'all', preferred_guest_ages: [19])

        expect(subject.eligible?(order)).to be false
      end
    end

    context 'match_policy: any' do
      it 'eligble when some guests current age include in selected guest_ages' do
        subject = described_class.new(preferred_match_policy: 'any', preferred_guest_ages: [17])

        expect(subject.eligible?(order)).to be true
      end

      it 'not eligible when guest current age is not include in selected guest_ages' do
        subject = described_class.new(preferred_match_policy: 'any', preferred_guest_ages: [unmatch_age])

        expect(subject.eligible?(order)).to be false
      end
    end

    after do
      Timecop.return
    end
  end
end