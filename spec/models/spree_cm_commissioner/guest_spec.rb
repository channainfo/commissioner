require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Guest, type: :model do
  let(:taxon) { create(:taxon, name: 'University Student') }
  let(:nationality) { create(:taxon, name: 'Khmer') }
  let(:line_item) { create(:line_item) }
  let(:id_card) { create(:id_card) }

  subject { line_item.guests.new }

  describe '.complete' do
    let(:order1) { create(:order, completed_at: Date.current) }
    let(:order2) { create(:order, completed_at: nil) }

    let(:line_item1) { create(:line_item, order: order1) }
    let(:line_item2) { create(:line_item, order: order2) }

    let!(:guest1) { create(:guest, line_item: line_item1) }
    let!(:guest2) { create(:guest, line_item: line_item2) }

    it 'return guests that has complete line item' do
      expect(described_class.complete.to_a).to eq [guest1]
    end
  end

  describe '.unassigned_event' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
    let(:product) { create(:product, product_type: :ecommerce, taxons: [section]) }
    let(:line_item) { create(:line_item, product: product) }

    let!(:guest_with_event_id) { create(:guest, line_item: line_item) }
    let!(:guest_with_no_event_id) { create(:guest) }

    it 'return guests that has no assigned event_id' do
      expect(guest_with_event_id.event_id).to eq event.id
      expect(guest_with_no_event_id.event_id).to eq nil

      expect(described_class.unassigned_event.to_a).to eq [guest_with_no_event_id]
    end
  end

  describe '#allowed_checkout?' do
    context 'when guest_name kyc enabled' do
      it 'return false when first name is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = nil
        subject.last_name = 'Doe'

        expect(subject.allowed_checkout?).to be false
      end

      it 'return false when last name is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = 'Jan'
        subject.last_name = nil

        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when both first name & last name is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = 'Jan'
        subject.last_name = 'Doe'

        expect(subject.guest_name?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when guest_gender kyc enabled' do
      it 'return false when gender is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_gender])

        subject.gender = nil

        expect(subject.guest_gender?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when gender is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_gender])

        subject.gender = :male

        expect(subject.guest_gender?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when date of birth kyc enabled' do
      it 'return false when gender is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_dob])

        subject.dob = nil

        expect(subject.guest_dob?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when gender is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_dob])

        subject.dob = Date.current

        expect(subject.guest_dob?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when occupation kyc enabled' do
      it 'return false when occupation is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_occupation])

        subject.occupation = nil

        expect(subject.guest_occupation?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when occupation is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_occupation])

        subject.occupation = taxon

        expect(subject.guest_occupation?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when id card kyc enabled' do
      it 'return false when id_card is nil' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])

        subject.id_card = nil

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return false when id_card is invalid' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])
        allow(id_card).to receive(:allowed_checkout?).and_return(false)

        subject.id_card = id_card

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when id_card is allowed to checkout' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])
        allow(id_card).to receive(:allowed_checkout?).and_return(true)

        subject.id_card = id_card

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when nationality kyc enabled' do
      it 'return false when nationality is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_nationality])

        subject.nationality = nil

        expect(subject.guest_nationality?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when nationality is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_nationality])

        subject.nationality = nationality

        expect(subject.guest_nationality?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end
  end

  describe '#generate_bib_number' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event1) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:event2) { create(:taxon, name: 'BunPhum 2', taxonomy: taxonomy) }

    let(:product) { create(:cm_bib_number_product, product_type: :ecommerce, taxons: [event1, event2]) }

    let(:order) { create(:order, completed_at: Date.current) }

    let(:line_item1) { create(:line_item, order: order, variant: product.variants.first) }
    let(:line_item2) { create(:line_item, order: order, variant: product.variants.last) }

    context "when guest has the same prefix" do
      let!(:guest1) { create(:guest, line_item: line_item1) }
      let!(:guest2) { create(:guest, line_item: line_item1) }

      it 'generate bib_number for guest' do
        guest1.generate_bib_number
        guest2.generate_bib_number

        expect(guest1.bib_number).to eq '001'
        expect(guest2.bib_number).to eq '002'
        expect(guest1.full_bib_number).to eq '3KM001'
        expect(guest2.full_bib_number).to eq '3KM002'
      end
    end

    context "when guest has different prefix" do
      let!(:guest1) { create(:guest, line_item: line_item1) }
      let!(:guest2) { create(:guest, line_item: line_item2) }

      it 'generate bib_number for guest' do
        guest1.generate_bib_number
        guest2.generate_bib_number

        expect(guest1.bib_number).to eq '001'
        expect(guest2.bib_number).to eq '001'
        expect(guest1.full_bib_number).to eq '3KM001'
        expect(guest2.full_bib_number).to eq '5KM001'
      end
    end
  end
end
