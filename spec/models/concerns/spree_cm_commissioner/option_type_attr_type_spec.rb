require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OptionTypeAttrType do
  context 'validation' do
    describe '#ensure_name_is_not_changed' do
      context 'when object is being created' do
        it 'does not call :ensure_name_is_not_changed' do
          subject = build(:option_type, name: 'abc')
          subject.validate

          expect(subject).not_to receive(:ensure_name_is_not_changed)
          expect(subject.validate).to be true
        end
      end

      context 'when object is being updated' do
        it 'valid when name_changed? false' do
          subject = create(:option_type, name: 'abc')
          subject.name = 'abc'

          expect(subject.name_changed?).to be false
          expect(subject).to receive(:ensure_name_is_not_changed).and_call_original
          expect(subject).to be_valid
        end

        it 'valid when reserved_option? false' do
          subject = create(:option_type, name: 'abc')
          subject.name = 'xyz'

          expect(subject.name_changed?).to be true
          expect(subject.reserved_option?).to be false

          expect(subject).to receive(:ensure_name_is_not_changed).and_call_original
          expect(subject).to be_valid
        end

        it 'invalid when name changed & it is a reserved options' do
          subject = create(:option_type, name: Spree::OptionType::RESERVED_OPTIONS.keys.first, presentation: 'option')
          subject.name = 'xyz'

          expect(subject.name_changed?).to be true
          expect(subject.reserved_option?).to be true

          expect(subject).to receive(:ensure_name_is_not_changed).and_call_original
          expect(subject).not_to be_valid

          expect(subject.errors[:name]).to eq ['cannot be changed after it has been set']
        end
      end
    end
  end
end
