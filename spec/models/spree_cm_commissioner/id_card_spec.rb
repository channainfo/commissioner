require 'spec_helper'

RSpec.describe SpreeCmCommissioner::IdCard, type: :model do
  describe '#allowed_checkout?' do
    context 'id card with only front image' do
      subject { create(:id_card, front_image: create(:cm_front_image), back_image: nil) }

      it 'not allowed checkout for national_id_card' do
        subject.card_type = :national_id_card
        expect(subject.allowed_checkout?).to be false
      end

      it 'not allowed checkout for student_id_card' do
        subject.card_type = :student_id_card
        expect(subject.allowed_checkout?).to be false
      end

      it 'allowed checkout for passport' do
        subject.card_type = :passport
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'id card with only back image' do
      subject { create(:id_card, front_image: nil, back_image: create(:cm_back_image)) }

      it 'not allowed checkout for national_id_card' do
        subject.card_type = :national_id_card
        expect(subject.allowed_checkout?).to be false
      end

      it 'not allowed checkout for student_id_card' do
        subject.card_type = :student_id_card
        expect(subject.allowed_checkout?).to be false
      end

      it 'not allowed checkout for passport' do
        subject.card_type = :passport
        expect(subject.allowed_checkout?).to be false
      end
    end

    context 'id card with both front image & back image' do
      subject { create(:id_card, front_image: create(:cm_front_image), back_image: create(:cm_back_image)) }

      it 'allowed checkout for national_id_card' do
        subject.card_type = :national_id_card
        expect(subject.allowed_checkout?).to be true
      end

      it 'allowed checkout for student_id_card' do
        subject.card_type = :student_id_card
        expect(subject.allowed_checkout?).to be true
      end

      it 'allowed checkout for passport' do
        subject.card_type = :passport
        expect(subject.allowed_checkout?).to be true
      end
    end
  end
end
