require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OptionValueAttrType do
  context 'name validation' do
    context 'for attr_type: integer' do
      let(:option_type) { create(:option_type, attr_type: 'integer') }

      it 'invalid when input string' do
        subject = build(:option_value, option_type: option_type, name: 'Fake Name')

        expect(subject.valid?).to be false
      end

      it 'invalid when input float' do
        subject = build(:option_value, option_type: option_type, name: '123.9')

        expect(subject.valid?).to be false
      end

      it 'valid when input integer' do
        subject0 = build(:option_value, option_type: option_type, name: 123)
        subject1 = build(:option_value, option_type: option_type, name: '123')

        expect(subject0.valid?).to be true
        expect(subject1.valid?).to be true
      end
    end

    context 'for attr_type: float' do
      let(:option_type) { create(:option_type, attr_type: 'float') }

      it 'invalid when input string' do
        subject = build(:option_value, option_type: option_type, name: 'Fake Name')

        expect(subject.valid?).to be false
      end

      it 'valid when input float' do
        subject0 = build(:option_value, option_type: option_type, name: '123.0')
        subject1 = build(:option_value, option_type: option_type, name: 123.0)

        expect(subject0.valid?).to be true
        expect(subject1.valid?).to be true
      end

      it 'valid when input integer' do
        subject0 = build(:option_value, option_type: option_type, name: '123')
        subject1 = build(:option_value, option_type: option_type, name: 123)

        expect(subject0.valid?).to be true
        expect(subject1.valid?).to be true
      end
    end

    context 'for attr_type: boolean' do
      let(:option_type) { create(:option_type, attr_type: 'boolean') }

      it 'valid when input 1 or 0 in integer' do
        subject0 = build(:option_value, option_type: option_type, name: 0)
        subject1 = build(:option_value, option_type: option_type, name: 1)

        expect(subject0.valid?).to be true
        expect(subject1.valid?).to be true
      end

      it 'valid when input string 1 or 0' do
        subject0 = build(:option_value, option_type: option_type, name: "0")
        subject1 = build(:option_value, option_type: option_type, name: "1")

        expect(subject0.valid?).to be true
        expect(subject1.valid?).to be true
      end

      it 'invalid when input other than 1 or 0' do
        subject0 = build(:option_value, option_type: option_type, name: '2')
        subject1 = build(:option_value, option_type: option_type, name: 3)

        expect(subject0.valid?).to be false
        expect(subject1.valid?).to be false
      end
    end

    context 'for attr_type: time' do
      let(:option_type) { create(:option_type, attr_type: 'time') }

      it 'invalid when input is in wrong format' do
        subject = build(:option_value, option_type: option_type, name: 'Invalid Presentation')

        expect(subject.valid?).to be false
      end

      it 'valid when input is in right format from time_select' do
        subject = build(:option_value, option_type: option_type, name: '{"time"=>{"(1i)"=>"2024", "(2i)"=>"6", "(3i)"=>"5", "(4i)"=>"17", "(5i)"=>"00"}}')

        expect(subject.valid?).to be true
      end

      it 'valid when input is in right format from normal format' do
        subject = build(:option_value, option_type: option_type, name: '12:53:00')

        expect(subject.valid?).to be true
      end
    end

    context 'for attr_type: date' do
      let(:option_type) { create(:option_type, attr_type: 'date') }

      context 'when it is invalid' do
        it 'invalid when input is in wrong format' do
          subject = build(:option_value, option_type: option_type, name: 'Invalid Presentation')

          expect(subject.valid?).to be false
        end
      end

      context 'when it is valid' do
        it 'valid when user input name & presentation with correct format' do
          subject = build(:option_value, option_type: option_type, name: '2024-01-26', presentation: '2024-01-26')

          expect(subject.valid?).to be true
          expect(subject.name).to eq '2024-01-26'
          expect(subject.presentation).to eq '2024-01-26'
        end

        it 'valid when user input name & presentation with correct date (even different format)' do
          subject = build(:option_value, option_type: option_type, name: '2024-01-26', presentation: 'Jan, 26th 2024')

          expect(subject.valid?).to be true
          expect(subject.name).to eq '2024-01-26'
          expect(subject.presentation).to eq 'Jan, 26th 2024'
        end

        it 'reset presentation when it is different from actual date' do
          subject = build(:option_value, option_type: option_type, name: '2024-01-26', presentation: 'Feb, 28th 2024')

          expect(subject.valid?).to be true
          expect(subject.name).to eq '2024-01-26'
          expect(subject.presentation).to eq '2024-01-26'
        end
      end
    end

    context 'for attr_type: delivery_option' do
      let(:option_type) { create(:option_type, attr_type: 'delivery_option') }

      context 'when name is [delivery or pickup]' do
        it 'valid' do
          subject1 = build(:option_value, option_type: option_type, name: 'delivery', presentation: 'Delivery 🚚')
          subject2 = build(:option_value, option_type: option_type, name: 'pickup', presentation: 'Pickup 📦')

          expect(subject1.valid?).to be true
          expect(subject2.valid?).to be true
        end
      end

      context 'when name is not [delivery or pickup]' do
        it 'invalid' do
          subject1 = build(:option_value, option_type: option_type, name: 'other', presentation: 'Other')
          subject2 = build(:option_value, option_type: option_type, name: 'fake', presentation: 'Fake Sth')

          expect(subject1.valid?).to be false
          expect(subject2.valid?).to be false
        end
      end
    end

    context 'for attr_type: coordinate' do
      let(:option_type) { create(:option_type, attr_type: 'coordinate') }

      context 'when latitude and longitude are present and valid' do
        it 'is valid' do
          subject1 = build(:option_value, option_type: option_type, name: '11.565372500047507, 104.90414595740654', presentation: 'Shop')
          subject2 = build(:option_value, option_type: option_type, name: '11.561563475097078, 104.91379901699543', presentation: 'Olamya')
          subject3 = build(:option_value, option_type: option_type, name: '11.561563475097078, 104.91379901699543, any value here still valid', presentation: 'Olamya')

          expect(subject1.valid?).to be true
          expect(subject2.valid?).to be true
          expect(subject3.valid?).to be true
        end
      end

      context 'when latitude and longitude are present and invalid lat: (-90, 90), long: (-180, 180)' do
        it 'is invalid' do
          invalid_lat = build(:option_value, option_type: option_type, name: '-100, 104.90414595740654', presentation: 'Shop')
          invalid_long = build(:option_value, option_type: option_type, name: '11.561563475097078, 190', presentation: 'Olamya')
          wrong_input = build(:option_value, option_type: option_type, name: 'wrong input', presentation: 'Olamya')

          expect(invalid_lat.valid?).to be false
          expect(invalid_long.valid?).to be false
          expect(wrong_input.valid?).to be false
        end
      end

      context 'when latitude and longitude are missing' do
        it 'is valid' do
          subject1 = build(:option_value, option_type: option_type, name: '', presentation: 'Shop')
          subject2 = build(:option_value, option_type: option_type, name: nil, presentation: 'Olamya')

          expect(subject1.valid?).to be false
          expect(subject2.valid?).to be false
        end
      end
    end
  end

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

  describe '#latitude' do
    context 'when attr_type is coordinate & name is valid geocode' do
      let(:option_type) { create(:option_type, attr_type: 'coordinate') }
      subject { create(:option_value, option_type: option_type, name: '11.565372500047507, 104.90414595740654') }

      it 'latitude in float' do
        expect(subject.latitude).to eq 11.565372500047507
      end
    end
  end

  describe '#longitude' do
    context 'when attr_type is coordinate & name is valid geocode' do
      let(:option_type) { create(:option_type, attr_type: 'coordinate') }
      subject { create(:option_value, option_type: option_type, name: '11.565372500047507, 104.90414595740654') }

      it 'longitude in float' do
        expect(subject.longitude).to eq 104.90414595740654
      end
    end
  end

  describe '#time' do
    context 'when attr_type is time & is name valid time' do
      let(:option_type) { create(:option_type, attr_type: 'time') }
      subject { create(:option_value, option_type: option_type, name: '12:53:00') }

      it 'time in time object' do
        expect(subject.time).to eq Time.zone.parse('12:53:00')
      end
    end
  end

  describe '#date' do
    context 'when attr_type is date & is name valid date' do
      let(:option_type) { create(:option_type, attr_type: 'date') }
      subject { create(:option_value, option_type: option_type, name: '2024-01-26') }

      it 'date in date object' do
        expect(subject.date).to eq date('2024-01-26')
      end
    end
  end
end
