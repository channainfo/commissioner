require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRules::ExtraKids, type: :model do
  let(:options_klass) { SpreeCmCommissioner::Pricings::Options }
  let(:guest_options_klass) { SpreeCmCommissioner::Pricings::GuestOptions }

  subject { build(:cm_extra_kids_pricing_rule) }

  describe 'validations' do
    it 'invalid when min_extra_kids or max_extra_kids are not present' do
      subject.preferred_min_extra_kids = nil
      subject.preferred_max_extra_kids = nil

      subject.validate

      expect(subject.errors[:min_extra_kids]).to include('invalid_min_extra_kids')
      expect(subject.errors[:max_extra_kids]).to include('invalid_max_extra_kids')
    end

    it 'invalid when min_extra_kids or max_extra_kids <= 0' do
      subject.preferred_min_extra_kids = 0
      subject.preferred_max_extra_kids = -1

      subject.validate

      expect(subject.errors[:min_extra_kids]).to include('invalid_min_extra_kids')
      expect(subject.errors[:max_extra_kids]).to include('invalid_max_extra_kids')
    end

    it 'invalid when min_extra_kids is greater than max_extra_kids' do
      subject.preferred_min_extra_kids = 5
      subject.preferred_max_extra_kids = 2

      subject.validate

      expect(subject.valid?).to be false
      expect(subject.errors[:extra_kids]).to include('invalid_extra_kids')
    end

    it 'valid when when min_extra_kids and max_extra_kids are present' do
      subject.preferred_min_extra_kids = 2
      subject.preferred_max_extra_kids = 5

      subject.validate

      expect(subject.valid?).to be true
    end
  end

  describe '#applicable?' do
    it 'returns true when options contain extra_kids' do
      options = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 1))
      expect(subject.applicable?(options)).to be true
    end

    it 'returns false when options do not contain booking date' do
      options = options_klass.new(guest_options: guest_options_klass.new(extra_kids: nil))
      expect(subject.applicable?(options)).to be false
    end

    it 'returns false when options is not instance of Pricings::GuestOptions' do
      options = double(:some_randome_class)
      expect(subject.applicable?(options)).to be false
    end
  end

  describe '#eligible?' do
    subject { build(:cm_extra_kids_pricing_rule, preferred_min_extra_kids: 1, preferred_max_extra_kids: 3) }

    it 'returns true when extra kids is within preferred range' do
      options1 = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 1))
      options2 = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 2))
      options3 = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 3))

      expect(subject.eligible?(options1)).to be true
      expect(subject.eligible?(options2)).to be true
      expect(subject.eligible?(options3)).to be true
    end

    it 'returns false when extra kids do not fall within preferred range' do
      options1 = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 0))
      options2 = options_klass.new(guest_options: guest_options_klass.new(extra_kids: 4))

      expect(subject.eligible?(options1)).to be false
      expect(subject.eligible?(options2)).to be false
    end
  end

  describe '#description' do
    context 'when min extra kids equals max extra kids' do
      it 'returns the correct description' do
        subject.preferred_min_extra_kids = 1
        subject.preferred_max_extra_kids = 1

        expect(subject.description).to eq('Booking with extra 1 kids')
      end
    end

    context 'when min extra kids is not equal to max extra kids' do
      it 'returns the correct description' do
        subject.preferred_min_extra_kids = 1
        subject.preferred_max_extra_kids = 3

        expect(subject.description).to eq('Booking with extra 1-3 kids')
      end
    end
  end
end
