require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Guest, type: :model do
  let(:taxon) { create(:taxon, name: 'University Student') }
  let(:nationality) { create(:taxon, name: 'Khmer') }
  let(:line_item) { create(:line_item) }
  let(:id_card) { create(:id_card) }

  subject { line_item.guests.new }

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
end
