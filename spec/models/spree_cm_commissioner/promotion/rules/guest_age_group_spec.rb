require 'spec_helper'
require 'timecop'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::GuestAgeGroup do
  describe '#eligible?' do
    let(:product) { create(:product, name: "TedTalk Adult Ticket", kyc: 1 ) }
    let(:taxonomy) { create(:taxonomy, kind: :occupation) }

    let(:young_adult_guest1) { create(:guest ,dob: 21.years.ago) }
    let(:young_adult_guest2) { create(:guest ,dob: 22.years.ago) }
    let(:uneligable_guest) { create(:guest ,dob: 2.years.ago) }

    let(:line_item1) { build(:line_item, product: product, guests:[young_adult_guest1, young_adult_guest2]) }
    let(:line_item2) { build(:line_item, product: product, guests:[young_adult_guest1, young_adult_guest2, uneligable_guest]) }

    let(:order1) { create(:order, line_items: [line_item1]) }
    let(:order2) { create(:order, line_items: [line_item2]) }

    let(:young_adults) { [20,29] }
    let(:seniors) { [60,99] }

    context 'match_policy: all' do

      it 'eligble when all guests current age include in selected age_group' do
        subject = described_class.new(preferred_match_policy: 'all', preferred_guest_age_group: [:young_adults])

        expect(subject.eligible?(order1)).to be true
      end

      it 'not eligible when some guests current age is not include in selected age_group' do
        subject = described_class.new( preferred_match_policy: 'all', preferred_guest_age_group: [:seniors])

        expect(subject.eligible?(order1)).to be false
      end

      it 'not eligble when all guests is not include in selected age_group' do
        subject = described_class.new(preferred_match_policy: 'all', preferred_guest_age_group: [:young_adults])

        expect(subject.eligible?(order2)).to be false
      end
    end

    context 'match_policy: any' do
      it 'eligble when some guests current age include in selected age_group' do
        subject = described_class.new(preferred_match_policy: 'any', preferred_guest_age_group: [:young_adults])

        expect(subject.eligible?(order2)).to be true
      end

      it 'not eligible when guest current age is not include in selected age_group' do
        subject = described_class.new(preferred_match_policy: 'any', preferred_guest_age_group: [:seniors])

        expect(subject.eligible?(order1)).to be false
      end
    end
  end
end